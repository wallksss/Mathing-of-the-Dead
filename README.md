# Mathing of the Dead

Um jogo de matemática com zumbis: cada zumbi que avança pelo cemitério
carrega uma **placa com quatro dígitos**. Mantendo os dígitos na ordem, você
acrescenta operadores e um `=` para formar uma **igualdade verdadeira** e
atira antes que o zumbi o alcance.

```
placa 8 1 3 1   →   √(8 + 1) = 3**1
```

Logo abaixo da sua fórmula, o jogo mostra a mesma expressão renderizada em
LaTeX: $\sqrt{8 + 1} = 3^{1}$.

Inspirado no [Emplake](https://www.cyan-lang.org/emplake/), do
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

- O `=` já começa na placa, porque sempre é necessário. Ele pode ser movido,
  mas existe só um.
- Os dígitos nunca são concatenados: `1 2` não é doze. Dois números seguidos
  sem operação dão erro.
- Depois de atirar, os operadores voltam voando para o cinto de munição.

## Níveis

| Nível | Operadores | Divisão não inteira |
|---|---|---|
| Fácil | `+ - × ÷ ( ) √ ∛ ! ** \|x\| ⌊x⌋ ⌈x⌉` | permitida (`5/2 = 2.5`) |
| Intermediário | `+ - × ÷ ( ) √ ∛ ! ** \|x\|` | erro |
| Avançado | `+ - × ÷ ( ) √ ! \|x\|` | erro |
| Difícil | `+ - × ÷ ( ) \|x\|` | erro |

O sinal de menos unário (`-(2 - 5)`) é aceito em todos os níveis.

**Precedência** (igual ao Emplake original):

- `×` e `÷` vêm antes de `+` e `−`: `1 + 2 × 3 = 7`.
- `√` e `∛` valem só para o número logo à frente, e `!` só para o que vem
  antes: `√9! = (√9)! = 6` e `2 × 3! = 12`.
- O `−` unário vale para o número ou expressão que o segue: `-2 + 2 = 0`,
  `--2 = 2`.
- Parênteses mudam a ordem: `√(9!)`, `(-2)…`.
- O `!` de um número não inteiro usa a parte inteira: `(√8)! = 2! = 2`.

- `⌊x⌋` (base) é o maior inteiro menor ou igual a `x`.
- `⌈x⌉` (teto) é o menor inteiro maior ou igual a `x`.
- `|x|` (módulo) é `x` se `x ≥ 0`, ou `-x` caso contrário.

## Pontuação, vidas e ajuda

- **Pontos**: cada nível tem uma base (10 / 20 / 35 / 50 por placa), mais um
  bônus de tempo (até +50%) e um bônus de sequência (+10% por acerto seguido,
  até +100%).
- **Vidas**: são três. Se o zumbi chegar até você, você perde uma vida e o
  jogo mostra uma solução possível. A velocidade dos zumbis é configurável,
  inclusive o modo **Zen**, sem limite de tempo.
- **Dica**: um solucionador embutido procura uma resposta, ao custo de 75%
  dos pontos da placa. Em placas muito difíceis ele pode não achar a resposta
  a tempo.
- **Toda placa tem solução**: placas impossíveis com os operadores do nível
  nunca aparecem. Só o Difícil, que não tem fatorial nem raiz, tem placas
  assim: mais da metade das combinações (como 0124) fica de fora.
- **Acerto**: ao acertar, o zumbi cai e o jogo mostra a fórmula resolvida e
  os pontos até você pedir o próximo zumbi.
- **Erro**: os operadores ficam na placa para você corrigir de onde parou.
- **Pular**: se uma placa parecer difícil demais, troque por outra. O zumbi
  continua de onde estava, então pular custa o tempo já gasto.
- **Progresso**: as placas resolvidas ficam salvas na sua conta e nunca mais
  aparecem no mesmo nível.

## Outras telas

- **Ranking**: a pontuação dos jogadores.
- **Cemitério**: o histórico das placas que você já resolveu.
- **Configurações**: tema claro ou escuro (o padrão segue o do dispositivo),
  temas prontos, cor semente, tipo e tamanho da fonte, idioma e som. O som
  começa desligado.
- **Ajuda**: um resumo das regras, disponível na barra de navegação.

O jogo está disponível em português, inglês e espanhol, e funciona no
celular, no computador e no navegador.
