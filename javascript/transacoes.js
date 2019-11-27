var data = [];

const getData = async () => {
    const res = await fetch('./transacoes.json', { method: 'GET', mode: 'no-cors' });
    res.json().then(res => data = res);

};

const functions = {
    filterTransaction: (filter) => data.filter(filter),
    filterByYearAndMonth: (year, month, transaction) => transaction ? transaction.datas.year === year && (month !== "" ? transaction.datas.month === month : true) : false,
    isIncomeOrExpense: (transaction) => !transaction.tipos.includes("SALDO_CORRENTE") && !transaction.tipos.includes("APLICACAO") && !transaction.tipos.includes("VALOR_APLICACAO"),
    isIncome: (transaction) => functions.isIncomeOrExpense(transaction) && transaction.valor > 0,
    isExpense: (transaction) => functions.isIncomeOrExpense(transaction) && transaction.valor < 0,
    filterIncomes: (data) => data.filter(functions.isIncome),
    filterExpenses: (data) => data.filter(functions.isExpense),
    sum: (data) => data.reduce((acumulator, actual) => acumulator + actual.valor, 0),
    getOver: (data) => functions.sum(functions.filterIncomes(data)) + functions.sum(functions.filterExpenses(data)),
    getInitialBalance: (data) => data.filter((transaction) => transaction.tipos.includes("SALDO_CORRENTE"))[0],
    getFinalBalance: (data) => functions.getInitialBalance(data).valor + functions.getOver(data),
    getMaxOrMinBalance: (data, comparator) => data.reduce((acumulator, transaction) => {

        const actualBalance = functions.isIncomeOrExpense(transaction) ? (acumulator.balance + transaction.valor) : acumulator.balance;
        const maxOrMinBalance = comparator(actualBalance, acumulator.maxOrMinBalance) ? actualBalance : acumulator.maxOrMinBalance;
        return { balance: actualBalance, maxOrMinBalance: maxOrMinBalance };
    },
        { balance: functions.getInitialBalance(data).valor, maxOrMinBalance: functions.getInitialBalance(data).valor }),

    range: (start, end, length = end - start) => Array.from({ length }, (_, i) => start + i),

    getMonths: (year) => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map(month => filterTransactionByYearAndMonth(year, month).length > 0),

    getIncomesOrExpenseAverage: (year, filter) => {
        const data = functions.getMonths(year).map((month, i) => month ? filter(year, i) : null).filter(average => average !== null);
        const sum = data.reduce((a, b) => a + b, 0)
        return sum / data.length;
    },
    getIncomesAverage: (year) => functions.getIncomesOrExpenseAverage(year, filterIncomes),

    getExpensesAverage: (year) => functions.getIncomesOrExpenseAverage(year, filterExpenses),

    getOversAverage: (year) => functions.getIncomesAverage(year) + functions.getExpensesAverage(year),

    getCashFlow: (data) => {

        const initialBalance = functions.getInitialBalance(data);

        if (data.length > 0) {

            const dataFiltered = data.filter(functions.isIncomeOrExpense);
            const cashFlow = dataFiltered.reduce((acumulator, transaction) => {

                const date = transaction.datas;
                const balance = acumulator.balance + transaction.valor;
                const days = { ...acumulator.days };
                days[date.dayOfMonth] = { dia: date.dayOfMonth, saldoFinalDoDia: balance };

                return { balance: balance, days: days };
            }, { balance: initialBalance.valor, days: { 1: { dia: 1, saldoFinalDoDia: initialBalance.valor } } });


            return cashFlow.days;
        }

        else {
            return {};
        }

    }
}


// Facade

const filterTransactionByYear = (year) => functions.filterTransaction((e) => functions.filterByYearAndMonth(year, "", e));
const filterTransactionByYearAndMonth = (year, month) => functions.filterTransaction((e) => functions.filterByYearAndMonth(year, month, e));
const filterIncomes = (year, month) => functions.sum(functions.filterIncomes(filterTransactionByYearAndMonth(year, month)));
const filterExpenses = (year, month) => functions.sum(functions.filterExpenses(filterTransactionByYearAndMonth(year, month)));
const getOver = (year, month) => functions.getOver(filterTransactionByYearAndMonth(year, month));
const getFinalBalance = (year, month) => functions.getFinalBalance(filterTransactionByYearAndMonth(year, month));
const getMaxBalance = (year, month) => functions.getMaxOrMinBalance(filterTransactionByYearAndMonth(year, month), (a, b) => a > b);
const getMinBalance = (year, month) => functions.getMaxOrMinBalance(filterTransactionByYearAndMonth(year, month), (a, b) => a < b);
const getIncomesAverage = (year) => functions.getIncomesAverage(year);
const getExpensesAverage = (year) => functions.getExpensesAverage(year);
const getOversAverage = (year) => functions.getOversAverage(year);
const getCashFlow = (year, month) => functions.getCashFlow(filterTransactionByYearAndMonth(year, month));

getData();