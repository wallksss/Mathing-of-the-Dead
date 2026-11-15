# Mathing of the Dead

Um jogo no estilo *The Typing of the Dead*, mas com matemática: cada zumbi
carrega uma **placa com quatro dígitos**. Mantendo os dígitos na ordem, o
jogador acrescenta operadores e um `=` para formar uma **igualdade
verdadeira** antes que o zumbi o alcance.

```
placa 8 1 3 1   →   √(8 + 1) = 3**1   →   \sqrt{8 + 1} = 3^{1}
```

Engenharia reversa do [Emplake](https://www.cyan-lang.org/emplake/), do
Prof. Walter Carnielli (os direitos do jogo original são dele).

## Como jogar

| Ação | Toque / mouse | Teclado |
|---|---|---|
| Mirar (mover o cursor) | tocar no espaço entre os dígitos | `←` `→` `Home` `End` |
| Carregar operador | tocar no cartucho do cinto de munição | `+ - * / ( ) ! =` |
| Potência `**` | `xʸ` | `**` ou `^` |
| Raiz quadrada / cúbica | `√` / `∛` | `s` / `c` |
| Módulo, base (piso), teto | `\|x\|`, `⌊x⌋`, `⌈x⌉` (abre/fecha sozinho) | `\|`, `[ ]`, `{ }` |
| Passar por um dígito | — | digitar o próprio dígito |
| Remover operador | tocar no operador da placa | `Backspace` / `Delete` |
| Atirar (verificar) | **Atirar!** | `Enter` |
| Limpar | **Limpar** | `Esc` |

O `=` já começa na placa (ele sempre é necessário) e pode ser movido; só
existe um. Dígitos nunca são concatenados (`1 2` não é doze), como no
original ("Erro: dois números sem operação").

### Níveis

| Nível | Operadores | Divisão não inteira |
|---|---|---|
| Fácil | `+ - × ÷ ( ) √ ∛ ! ** \|x\| ⌊x⌋ ⌈x⌉` | permitida (`5/2 = 2.5`) |
| Intermediário | `+ - × ÷ ( ) √ ∛ ! ** \|x\|` | erro |
| Avançado | `+ - × ÷ ( ) √ ! \|x\|` | erro |
| Difícil | `+ - × ÷ ( ) \|x\|` | erro |

O sinal de menos unário (`-(2 - 5)`) é aceito em todos os níveis.

### Pontuação, vidas e dicas

- Pontos base por nível (10/20/35/50) + bônus de tempo (até +50%) + bônus de
  sequência (+10% por acerto seguido, até +100%).
- Três vidas: se o zumbi chegar, perde-se uma vida e o jogo mostra uma
  solução possível. A velocidade dos zumbis é configurável (inclusive o modo
  **Zen**, sem tempo).
- **Dica**: um solucionador embutido procura uma resposta (custa 75% dos
  pontos da placa). Algumas placas são realmente difíceis e o solucionador
  pode não encontrar resposta — nesses casos, **Pular**.
- Placas resolvidas ficam salvas no Firestore e **nunca mais aparecem** no
  mesmo nível.

## Requisitos do trabalho → onde estão

| Requisito | Implementação |
|---|---|
| Operadores por nível; divisão não inteira só no Fácil | `lib/game/engine/difficulty.dart`, `ast.dart` |
| Fórmula em LaTeX logo abaixo da fórmula do usuário | `flutter_math_fork` em `game_page.dart` (`plateToLatex`) |
| Interface única | cena do cemitério + placa de carro editável + cinto de munição + teclado estilo *Typing of the Dead* |
| Som opcional (desligado por padrão) | `lib/audio/sound_service.dart` (sons sintetizados em Dart) |
| Versão web | `flutter build web`; deploy por GitHub Pages ou Firebase Hosting |
| Login com `firebase_ui_auth` (e-mail/senha e Google) | `lib/auth/login_page.dart`, `main.dart` |
| Nomes do grupo e escolha de idioma com bandeiras no login | `AppConfig.groupMembers`, `LanguagePicker` (`country_flags`) |
| Todos os textos traduzidos (pt, en, es) com `flutter_localizations` | `lib/l10n/*.arb` → `lib/l10n/generated/` |
| Barra de navegação curva sempre presente, com configurações e ajuda (`showDialog`) | `lib/shell/app_shell.dart` (`curved_navigation_bar`) |
| Configurações: claro/escuro, tamanho e tipo da fonte, cor semente, temas prontos; tema do dispositivo por padrão | `lib/settings/` |
| Voltar à página em que estava (SharedPreferences) | `routing/router.dart` (última rota) + `game_controller.dart` (partida em andamento) |
| `flutter_riverpod` | configurações, autenticação, repositório, estado do jogo, versão dos dados |
| `go_router` | `lib/routing/router.dart` (`StatefulShellRoute`) |
| Animação | operadores voltam voando para os botões; zumbi andando/caindo; placa tremendo no erro |
| Firestore + `FutureBuilder` + indicador de progresso não padrão | níveis, jogo, ranking, cemitério e conta usam `FutureBuilder` com `loading_animation_widget` |
| Guardar números resolvidos e só mostrar não resolvidos | `UserRepository.solvedPlates` / `GameController._pickPlate` |
| Pular número difícil | botão **Pular** |
| Responsivo (celular, desktop, web) | `LayoutBuilder` em todas as páginas |

## Configuração

Pré-requisitos: Flutter 3.50+ (stable).

### 1. Firebase (plano Spark, gratuito)

1. Crie um projeto em <https://console.firebase.google.com>.
2. **Authentication → Sign-in method**: habilite *E-mail/senha* e *Google*.
   Em *Google → Configuração do SDK da Web*, copie o **ID do cliente Web**.
3. **Firestore Database**: crie o banco e publique as regras de
   [`firestore.rules`](firestore.rules).
4. Gere `lib/firebase_options.dart`:

   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=web,android
   ```

5. Coloque o ID do cliente Web em `lib/config/app_config.dart`
   (ou use `--dart-define=GOOGLE_CLIENT_ID=...`).
6. Em **Authentication → Settings → Authorized domains**, adicione o domínio
   onde o app será hospedado (ex.: `usuario.github.io`).

Enquanto o Firebase não estiver configurado, o app mostra uma tela explicando
o que fazer, em vez de travar.

### 2. Nomes do grupo

Edite `AppConfig.groupMembers` em `lib/config/app_config.dart`.

### 3. Executar

```sh
flutter pub get
flutter run -d chrome
```

Para ver a interface sem Firebase (dados falsos em memória):

```sh
flutter run -d chrome -t tool/preview_main.dart
```

### 4. Publicar na web

- **GitHub Pages**: o workflow [`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml)
  publica a cada push na `main` (ative *Settings → Pages → Source: GitHub Actions*).
- **Firebase Hosting**: `flutter build web && firebase deploy`.

## Arquitetura

```
lib/
  game/engine/     motor puro em Dart: tokens, parser, avaliação, LaTeX, solucionador
  game/            controlador do jogo (Riverpod), páginas e widgets (cena, placa, cinto)
  data/            modelos e repositório do Firestore
  routing/         go_router + restauração da última página
  settings/        configurações persistidas (SharedPreferences) e página
  auth/ shell/ ranking/ history/ widgets/ theme/ audio/ l10n/
```

Testes: `flutter test` (motor matemático, solucionador e controlador do jogo).

> **Nota técnica:** no Flutter 3.47+ `package:flutter/material.dart` foi
> marcado como obsoleto em favor de `package:material_ui`. Como
> `firebase_ui_auth`, `flutter_localizations`, `flutter_math_fork` e
> `curved_navigation_bar` ainda usam `flutter/material`, e misturar as duas
> bibliotecas quebra o `Theme` e as localizações, o app usa
> `flutter/material` (o aviso está desativado em `analysis_options.yaml`) e
> o `google_fonts` foi fixado na versão 8.x pelo mesmo motivo.
