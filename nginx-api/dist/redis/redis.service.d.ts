import { OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';
export declare class RedisService implements OnModuleInit {
    private client;
    onModuleInit(): void;
    getClient(): Redis;
}
