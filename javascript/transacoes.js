var data = require('./transacoes.json');




const functions = {
filterTransaction : (filter) => data.filter(filter),
filterByYearAndMonth : (year, month, transaction) =>  transaction.datas.year === year && (month ? transaction.datas.month === month : true),
isIncomeOrExpense: (transaction) => !transaction.tipos.includes("SALDO_CORRENTE","APLICACAO","VALOR_APLICACAO") ,
isIncome: (transaction) =>  isIncomeOrExpense(transaction) && transaction.valor > 0,
isExpense: (transaction) => isIncomeOrExpense(transaction) && transaction.valor < 0,
filterIncomes: (data) => data.filter(isIncome),
filterExpenses: (data) => data.filter(isExpense),
sum: (data) => data.reduce((acumulator , actual) => acumulator + actual.valor),
getOver: (data) => sum(filterIncomes(data)) - sum(filterExpenses(data)),
getInitialBalance: (data) => data.filter((transaction) => transaction.tipos.includes("SALDO_CORRENTE"))[0],
getFinalBalance: (data) => getInitialBalance(data).valor + getOver(data),

//getMaxBalance
}

filterTransactionByYear = (year) => functions.filterTransaction((e) => functions.filterByYearAndMonth(year, null, e));

filterTransactionByYearAndMonth = (year, month) => functions.filterTransaction((e) => functions.filterByYearAndMonth(year, month, e));



