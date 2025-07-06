import { ListsService } from './lists.service';
import { IIpRule } from './lists.types';
import { CreateIpRuleDto, GetIpRulesQueryDto, UpdateIpRpsDto, UpdateIpStatusDto } from './lists.dto';
export declare class ListsController {
    private readonly listsService;
    constructor(listsService: ListsService);
    create(dto: CreateIpRuleDto): Promise<IIpRule>;
    findAll(query: GetIpRulesQueryDto): Promise<IIpRule[]>;
    findOne(id: string): Promise<IIpRule>;
    remove(id: string): Promise<void>;
    updateStatus(dto: UpdateIpStatusDto): Promise<IIpRule>;
    updateRps(dto: UpdateIpRpsDto): Promise<IIpRule>;
}
