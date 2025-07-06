import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { JwtAuthGuard } from './jwt/jwt.guard';

const ORIGINS: string[] = [
  'http://localhost:3000/',
  'https://dev.cringepay.xyz',
  'https://test.cringepay.xyz',
  'https://cringepay.xyz',
];

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // app.useGlobalGuards(new JwtAuthGuard());

  const config = new DocumentBuilder()
    .setTitle('Cringepay Admin TECH API')
    .setDescription('Логи, фильтры, блокировки, лимиты и т.д.')
    .setVersion('1.0')
    .build();
  app.setGlobalPrefix('api/tech');

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document, {
    useGlobalPrefix: true,
    swaggerOptions: {
      url: '/api/tech/docs-json',
    },
  });

  app.enableCors({
    origin: ORIGINS,
    credentials: false, // если нужны куки/авторизация
  });

  await app.listen(15000, '0.0.0.0');
}
bootstrap().catch((e) => console.log(e));
