"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ListsService = void 0;
const common_1 = require("@nestjs/common");
const redis_service_1 = require("../redis/redis.service");
const uuid_1 = require("uuid");
let ListsService = class ListsService {
    redisService;
    REDIS_KEY = 'ip_rules';
    constructor(redisService) {
        this.redisService = redisService;
    }
    get redis() {
        return this.redisService.getClient();
    }
    async createIpRule(dto) {
        const id = (0, uuid_1.v4)();
        const now = new Date().toISOString();
        const rule = {
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
    async getIpRules(query) {
        const all = await this.redis.hgetall(this.REDIS_KEY);
        const values = Object.values(all)
            .map((raw) => {
            try {
                return JSON.parse(raw);
            }
            catch {
                return null;
            }
        })
            .filter((v) => v !== null);
        const filtered = values.filter((rule) => {
            if (query.ip && rule.ip !== query.ip)
                return false;
            if (query.status && rule.status !== query.status)
                return false;
            if (query.domain && rule.domain !== query.domain)
                return false;
            return true;
        });
        filtered.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        const page = query.page ?? 1;
        const limit = query.limit ?? 50;
        const start = (page - 1) * limit;
        const end = start + limit;
        return filtered.slice(start, end);
    }
    async deleteIpRule(id) {
        const result = await this.redis.hdel(this.REDIS_KEY, id);
        if (!result)
            throw new common_1.NotFoundException('IP rule not found');
    }
    async updateIpStatus(id, dto) {
        const raw = await this.redis.hget(this.REDIS_KEY, id);
        if (!raw)
            throw new common_1.NotFoundException('IP rule not found');
        const rule = JSON.parse(raw);
        rule.status = dto.status;
        rule.updatedAt = new Date().toISOString();
        await this.redis.hset(this.REDIS_KEY, id, JSON.stringify(rule));
        return rule;
    }
    async updateIpRps(id, dto) {
        const raw = await this.redis.hget(this.REDIS_KEY, id);
        if (!raw)
            throw new common_1.NotFoundException('IP rule not found');
        const rule = JSON.parse(raw);
        rule.rps = dto.rps;
        rule.updatedAt = new Date().toISOString();
        await this.redis.hset(this.REDIS_KEY, id, JSON.stringify(rule));
        return rule;
    }
    async getById(id) {
        const raw = await this.redis.hget(this.REDIS_KEY, id);
        if (!raw)
            throw new common_1.NotFoundException('IP rule not found');
        return JSON.parse(raw);
    }
};
exports.ListsService = ListsService;
exports.ListsService = ListsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [redis_service_1.RedisService])
], ListsService);
//# sourceMappingURL=lists.service.js.map