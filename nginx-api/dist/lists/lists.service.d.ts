import { RedisService } from '../redis/redis.service';
import { EIpStatus, IIpRule } from './lists.types';
import { CreateIpRuleDto, GetIpRulesQueryDto } from './lists.dto';
export declare class ListsService {
    private readonly redisService;
    private readonly REDIS_KEY;
    constructor(redisService: RedisService);
    private get redis();
    createIpRule(dto: CreateIpRuleDto): Promise<IIpRule>;
    getIpRules(query: GetIpRulesQueryDto): Promise<IIpRule[]>;
    deleteIpRule(id: string): Promise<void>;
    updateIpStatus(id: string, dto: {
        status: EIpStatus;
    }): Promise<IIpRule>;
    updateIpRps(id: string, dto: {
        rps: number;
    }): Promise<IIpRule>;
    getById(id: string): Promise<IIpRule>;
}
