import { Injectable, NotFoundException } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { EIpStatus, IIpRule } from './lists.types';
import { CreateIpRuleDto, GetIpRulesQueryDto } from './lists.dto';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ListsService {
  private readonly REDIS_KEY = 'ip_rules';

  constructor(private readonly redisService: RedisService) {}

  private get redis() {
    return this.redisService.getClient();
  }

  async createIpRule(dto: CreateIpRuleDto): Promise<IIpRule> {
    const id = uuidv4();
    const now = new Date().toISOString();

    const rule: IIpRule = {
      id,
      ip: dto.ip,
      status: dto.status,
      domain: dto.domain,
      rps: dto.rps ?? 0,
      createdAt: now,
      updatedAt: now,
    };

    await this.redis.hset(this.REDIS_KEY, id, JSON.stringify(rule));
    return rule;
  }

  async getIpRules(query: GetIpRulesQueryDto): Promise<IIpRule[]> {
    const all = await this.redis.hgetall(this.REDIS_KEY);
    const values = Object.values(all)
      .map((raw) => {
        try {
          return JSON.parse(raw) as IIpRule;
        } catch {
          return null;
        }
      })
      .filter((v): v is IIpRule => v !== null);

    const filtered = values.filter((rule) => {
      if (query.ip && rule.ip !== query.ip) return false;
      if (query.status && rule.status !== query.status) return false;
      if (query.domain && rule.domain !== query.domain) return false;
      return true;
    });

    filtered.sort(
      (a, b) =>
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    );

    const page = query.page ?? 1;
    const limit = query.limit ?? 50;
    const start = (page - 1) * limit;
    const end = start + limit;

    return filtered.slice(start, end);
  }

  async deleteIpRule(id: string): Promise<void> {
    const result = await this.redis.hdel(this.REDIS_KEY, id);
    if (!result) throw new NotFoundException('IP rule not found');
  }

  async updateIpStatus(
    id: string,
    dto: { status: EIpStatus },
  ): Promise<IIpRule> {
    const raw = await this.redis.hget(this.REDIS_KEY, id);
    if (!raw) throw new NotFoundException('IP rule not found');

    const rule = JSON.parse(raw) as unknown as IIpRule;
    rule.status = dto.status;
    rule.updatedAt = new Date().toISOString();

    await this.redis.hset(this.REDIS_KEY, id, JSON.stringify(rule));
    return rule;
  }

  async updateIpRps(id: string, dto: { rps: number }): Promise<IIpRule> {
    const raw = await this.redis.hget(this.REDIS_KEY, id);
    if (!raw) throw new NotFoundException('IP rule not found');

    const rule = JSON.parse(raw) as unknown as IIpRule;
    rule.rps = dto.rps;
    rule.updatedAt = new Date().toISOString();

    await this.redis.hset(this.REDIS_KEY, id, JSON.stringify(rule));
    return rule;
  }

  async getById(id: string): Promise<IIpRule> {
    const raw = await this.redis.hget(this.REDIS_KEY, id);
    if (!raw) throw new NotFoundException('IP rule not found');
    return JSON.parse(raw) as IIpRule;
  }
}
