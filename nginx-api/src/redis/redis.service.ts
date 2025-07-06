import { Injectable, OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit {
  private client: Redis;

  onModuleInit() {
    this.client = new Redis({
      host: '127.0.0.1',
      port: 6379,
    });
  }

  getClient(): Redis {
    return this.client;
  }
}
