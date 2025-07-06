import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { RedisModule } from './redis/redis.module';
import { LogsModule } from './logs/logs.module';
import { ListsModule } from './lists/lists.module';
import { AuthModule } from './jwt/jwt.module';

@Module({
  imports: [RedisModule, LogsModule, ListsModule, AuthModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
