"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ListsModule = void 0;
const common_1 = require("@nestjs/common");
const lists_service_1 = require("./lists.service");
const lists_controller_1 = require("./lists.controller");
const redis_module_1 = require("../redis/redis.module");
let ListsModule = class ListsModule {
};
exports.ListsModule = ListsModule;
exports.ListsModule = ListsModule = __decorate([
    (0, common_1.Module)({
        imports: [redis_module_1.RedisModule],
        controllers: [lists_controller_1.ListsController],
        providers: [lists_service_1.ListsService],
    })
], ListsModule);
//# sourceMappingURL=lists.module.js.map