**Para execução do programa é necessário instalar dependências através dos seguintes comandos:**

``` 
$ cabal update
$ cabal install aeson
```

**Para executar:**

``` 
ghci Controller.hs
```

**Funções disponíveis**
1. Filtrar transações por ano. `filterAno ano`
2. Filtrar transações por ano e mês. `filterAnoMes ano mes`
3. Calcular o valor das receitas (créditos) em um determinado mês e ano. `calculaCredito ano mes`
4. Calcular o valor das despesas (débitos) em um determinado mês e ano. `calculaDebito ano mes`
5. Calcular a sobra (receitas - despesas) de determinado mês e ano `calculaSobra ano mes`
6. Calcular o saldo final em um determinado ano e mês `calculaSaldoFinalAnoMes ano mes`
7. Calcular o saldo máximo atingido em determinado ano e mês `getSaldoMax ano mes`
8. Calcular o saldo mínimo atingido em determinado ano e mês `getSaldoMin ano mes`
9. Calcular a média das receitas em determinado ano `getMediaCreditoAno ano`
10. Calcular a média das despesas em determinado ano `getMediaDebitoAno ano`
11. Calcular a média das sobras em determinado ano `getMediaSobrasAno ano`
12. Retornar o fluxo de caixa de determinado mês/ano. `getFluxo ano mes` 

