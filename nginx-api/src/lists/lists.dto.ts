import {
  IsEnum,
  IsInt,
  IsIP,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { EDomain, EIpStatus } from './lists.types';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { HostType } from '../logs/logs.types';

export class GetIpRulesQueryDto {
  @ApiPropertyOptional({
    description: 'IP-адрес (частичное или полное совпадение)',
  })
  @IsOptional()
  @IsIP()
  ip?: string;

  @ApiPropertyOptional({
    enum: EIpStatus,
    description: 'Статус IP (whitelist, blacklist)',
  })
  @IsOptional()
  @IsEnum(EIpStatus)
  status?: EIpStatus;

  @ApiPropertyOptional({
    enum: EDomain,
    description: 'Домен (dev, test, production)',
  })
  @IsOptional()
  @IsEnum(EDomain)
  domain?: EDomain;

  @ApiPropertyOptional({ default: 1, minimum: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 50, minimum: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  limit?: number = 50;
}

export class UpdateIpStatusDto {
  @ApiProperty({ description: 'ID записи' })
  @IsString()
  id: string;

  @ApiProperty({ enum: EIpStatus, description: 'Новый статус IP' })
  @IsEnum(EIpStatus)
  status: EIpStatus;
}

export class UpdateIpRpsDto {
  @ApiProperty({ description: 'ID записи' })
  @IsString()
  id: string;

  @ApiProperty({ description: 'Новый лимит RPS (0 — без ограничений)' })
  @IsInt()
  @Min(0)
  rps: number;
}

export class CreateIpRuleDto {
  @ApiProperty({ description: 'IP-адрес' })
  @IsIP()
  ip: string;

  @ApiProperty({
    enum: EIpStatus,
    description: 'Статус IP (whitelist или blacklist)',
  })
  @IsEnum(EIpStatus)
  status: EIpStatus;

  @ApiProperty({
    enum: HostType,
    description: 'Домен, к которому относится правило',
  })
  @IsEnum(EDomain)
  domain: EDomain;

  @ApiPropertyOptional({
    description: 'RPS лимит. 0 — без ограничений',
    default: 0,
  })
  @IsOptional()
  rps?: number = 0;
}
