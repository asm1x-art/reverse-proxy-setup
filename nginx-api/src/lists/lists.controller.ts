import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ListsService } from './lists.service';
import { IIpRule } from './lists.types';
import {
  CreateIpRuleDto,
  GetIpRulesQueryDto,
  UpdateIpRpsDto,
  UpdateIpStatusDto,
} from './lists.dto';
import { ApiOperation, ApiTags, ApiParam } from '@nestjs/swagger';

@ApiTags('IP Rules')
@Controller('lists')
export class ListsController {
  constructor(private readonly listsService: ListsService) {}

  @Post()
  @ApiOperation({ summary: 'Добавить новый IP' })
  async create(@Body() dto: CreateIpRuleDto): Promise<IIpRule> {
    return this.listsService.createIpRule(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Получить список IP с фильтрацией' })
  async findAll(@Query() query: GetIpRulesQueryDto): Promise<IIpRule[]> {
    return this.listsService.getIpRules(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Получить конкретный IP по ID' })
  @ApiParam({ name: 'id', type: 'string' })
  async findOne(@Param('id') id: string): Promise<IIpRule> {
    return this.listsService.getById(id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Удалить IP по ID' })
  @ApiParam({ name: 'id', type: 'string' })
  async remove(@Param('id') id: string): Promise<void> {
    return this.listsService.deleteIpRule(id);
  }

  @Patch('status')
  @ApiOperation({ summary: 'Обновить статус IP' })
  async updateStatus(@Body() dto: UpdateIpStatusDto): Promise<IIpRule> {
    return this.listsService.updateIpStatus(dto.id, { status: dto.status });
  }

  @Patch('rps')
  @ApiOperation({ summary: 'Обновить лимит RPS' })
  async updateRps(@Body() dto: UpdateIpRpsDto): Promise<IIpRule> {
    return this.listsService.updateIpRps(dto.id, { rps: dto.rps });
  }
}
