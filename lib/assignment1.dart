// banking_system.dart

abstract class InterestBearing {
  double calculateInterest();
}

// ------------------- Base Class -------------------
abstract class BankAccount {
  final String _accountNumber;
  final String _accountHolderName;
  double _balance;
  final String accountType;

  final List<String> _transactions = []; // Transaction history

  BankAccount(
    this._accountNumber,
    this._accountHolderName,
    this._balance,
    this.accountType,
  );

  // Getters
  String get accountNumber => _accountNumber;
  String get accountHolderName => _accountHolderName;
  double get balance => _balance;

  // Setter for encapsulation
  set balance(double newBalance) {
    _balance = newBalance;
  }

  // Abstract methods
  void withdraw(double amount);
  void deposit(double amount);

  // Add transaction
  void addTransaction(String details) {
    _transactions.add(details);
  }

  // Display account info
  void displayAccountInfo() {
    print("Account Number: $_accountNumber");
    print("Account Holder: $_accountHolderName");
    print("Balance: \$${_balance.toStringAsFixed(2)}");
    print("Account Type: $accountType");
  }

  // Display transaction history
  void showTransactionHistory() {
    print("\nTransaction History for $_accountHolderName:");
    if (_transactions.isEmpty) {
      print("No transactions yet.");
    } else {
      for (var tx in _transactions) {
        print("- $tx");
      }
    }
  }
}

// ------------------- Savings Account -------------------
class SavingsAccount extends BankAccount implements InterestBearing {
  int _withdrawals = 0;
  static const double minBalance = 500;
  static const double interestRate = 0.02;
  static const int maxWithdrawals = 3;

  SavingsAccount(String accNo, String name, double balance)
    : super(accNo, name, balance, "Savings");

  @override
  void withdraw(double amount) {
    if (_withdrawals >= maxWithdrawals) {
      print("Withdrawal limit reached for this month.");
      return;
    }

    if (balance - amount < minBalance) {
      print("Cannot withdraw. Minimum balance of \$500 required.");
    } else {
      balance -= amount;
      _withdrawals++;
      addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    }
  }

  @override
  void deposit(double amount) {
    balance += amount;
    addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  double calculateInterest() {
    double interest = balance * interestRate;
    balance += interest;
    addTransaction("Interest added: \$${interest.toStringAsFixed(2)}");
    return interest;
  }
}

// ------------------- Checking Account -------------------
class CheckingAccount extends BankAccount {
  static const double overdraftFee = 35.0;

  CheckingAccount(String accNo, String name, double balance)
    : super(accNo, name, balance, "Checking");

  @override
  void withdraw(double amount) {
    balance -= amount;
    if (balance < 0) {
      balance -= overdraftFee;
      addTransaction("Overdraft fee charged: \$35");
    }
    addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }

  @override
  void deposit(double amount) {
    balance += amount;
    addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }
}

// ------------------- Premium Account -------------------
class PremiumAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 10000;
  static const double interestRate = 0.05;

  PremiumAccount(String accNo, String name, double balance)
    : super(accNo, name, balance, "Premium");

  @override
  void withdraw(double amount) {
    if (balance - amount < minBalance) {
      print("Cannot withdraw. Minimum balance of \$10,000 required.");
    } else {
      balance -= amount;
      addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    }
  }

  @override
  void deposit(double amount) {
    balance += amount;
    addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  double calculateInterest() {
    double interest = balance * interestRate;
    balance += interest;
    addTransaction("Interest added: \$${interest.toStringAsFixed(2)}");
    return interest;
  }
}

// ------------------- Student Account -------------------
class StudentAccount extends BankAccount {
  static const double maxBalance = 5000;

  StudentAccount(String accNo, String name, double balance)
    : super(accNo, name, balance, "Student");

  @override
  void withdraw(double amount) {
    if (balance - amount < 0) {
      print(" Insufficient balance. Cannot withdraw.");
    } else {
      balance -= amount;
      addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    }
  }

  @override
  void deposit(double amount) {
    if (balance + amount > maxBalance) {
      print(" Deposit failed. Maximum balance of \$5,000 exceeded.");
    } else {
      balance += amount;
      addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
    }
  }
}

// ------------------- Bank Class -------------------
class Bank {
  final List<BankAccount> _accounts = [];

  void createAccount(BankAccount account) {
    _accounts.add(account);
    print(" Account created for ${account.accountHolderName}");
  }

  BankAccount? findAccount(String accNo) {
    for (var acc in _accounts) {
      if (acc.accountNumber == accNo) return acc;
    }
    print("Account not found for number: $accNo");
    return null;
  }

  void transfer(String fromAccNo, String toAccNo, double amount) {
    var fromAcc = findAccount(fromAccNo);
    var toAcc = findAccount(toAccNo);

    if (fromAcc != null && toAcc != null) {
      fromAcc.withdraw(amount);
      toAcc.deposit(amount);
      fromAcc.addTransaction(
        "Transferred \$${amount.toStringAsFixed(2)} to ${toAcc.accountHolderName}",
      );
      toAcc.addTransaction(
        "Received \$${amount.toStringAsFixed(2)} from ${fromAcc.accountHolderName}",
      );
      print("💸 Transfer of \$${amount.toStringAsFixed(2)} successful!");
    } else {
      print(" Transfer failed! Invalid account number(s).");
    }
  }

  void generateReport() {
    print("\n\tBANK REPORT\n");

    for (var acc in _accounts) {
      acc.displayAccountInfo();

      if (acc is InterestBearing) {
        // calculate interest preview (not applied again)
        double interestPreview =
            acc.balance * (acc.accountType == "Premium" ? 0.05 : 0.02);
        print(
          "Interest (${acc.accountType == "Premium" ? "5%" : "2%"}): \$${interestPreview.toStringAsFixed(2)}",
        );
      } else {
        print("Interest: Not Applicable");
      }

      print("");
    }

    for (var acc in _accounts) {
      acc.showTransactionHistory();
    }
  }
}

// ------------------- Main -------------------
void main() {
  Bank bank = Bank();

  var acc1 = SavingsAccount("1001", "Ankit", 1300);
  var acc2 = CheckingAccount("1002", "Sujal", 500);
  var acc3 = PremiumAccount("1003", "Aayush", 14500);
  var acc4 = StudentAccount("1004", "Nipuana", 3000);

  bank.createAccount(acc1);
  bank.createAccount(acc2);
  bank.createAccount(acc3);
  bank.createAccount(acc4);

  acc1.withdraw(200);
  acc1.deposit(500);
  acc2.withdraw(635); // overdraft
  acc3.withdraw(1000);
  acc4.withdraw(1000);

  bank.transfer("1003", "1001", 500);
  bank.generateReport();
}
