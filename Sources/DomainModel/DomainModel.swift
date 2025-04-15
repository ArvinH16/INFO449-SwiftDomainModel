struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    public var amount: Int
    public var currency: String
    
    public init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    public func convert(_ targetCurrency: String) -> Money {
        var usdAmount = amount
        if currency != "USD" {
            switch currency {
            case "GBP":
                usdAmount = amount * 2
            case "EUR":
                usdAmount = Int(Double(amount) / 1.5)
            case "CAN":
                usdAmount = Int(Double(amount) / 1.25)
            default:
                return self
            }
        }
        
        switch targetCurrency {
        case "USD":
            return Money(amount: usdAmount, currency: "USD")
        case "GBP":
            return Money(amount: usdAmount / 2, currency: "GBP")
        case "EUR":
            return Money(amount: Int(Double(usdAmount) * 1.5), currency: "EUR")
        case "CAN":
            return Money(amount: Int(Double(usdAmount) * 1.25), currency: "CAN")
        default:
            return self
        }
    }
    
    public func add(_ other: Money) -> Money {
        let otherInUSD = other.convert("USD")
        let selfInUSD = self.convert("USD")
        let totalInUSD = Money(amount: otherInUSD.amount + selfInUSD.amount, currency: "USD")
        return totalInUSD.convert(other.currency)
    }
    
    public func subtract(_ other: Money) -> Money {
        let otherInUSD = other.convert("USD")
        let selfInUSD = self.convert("USD")
        let totalInUSD = Money(amount: selfInUSD.amount - otherInUSD.amount, currency: "USD")
        return totalInUSD.convert(other.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    public var title: String
    public var type: JobType
    
    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    public func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case .Salary(let amount):
            return Int(amount)
        case .Hourly(let rate):
            return Int(rate * Double(hours))
        }
    }
    
    public func raise(byAmount amount: Double) {
        switch type {
        case .Salary(let current):
            type = .Salary(UInt(Double(current) + amount))
        case .Hourly(let current):
            type = .Hourly(current + amount)
        }
    }
    
    public func raise(byPercent percent: Double) {
        switch type {
        case .Salary(let current):
            type = .Salary(UInt(Double(current) * (1 + percent)))
        case .Hourly(let current):
            type = .Hourly(current * (1 + percent))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public var firstName: String
    public var lastName: String
    public var age: Int
    private var _job: Job?
    private var _spouse: Person?
    
    public var job: Job? {
        get { return _job }
        set {
            if age >= 18 {
                _job = newValue
            } else {
                _job = nil
            }
        }
    }
    
    public var spouse: Person? {
        get { return _spouse }
        set {
            if age >= 18 {
                _spouse = newValue
            } else {
                _spouse = nil
            }
        }
    }
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    public func toString() -> String {
        var jobStr = "nil"
        if let job = job {
            switch job.type {
            case .Salary(let amount):
                jobStr = "Salary(\(amount))"
            case .Hourly(let rate):
                jobStr = "Hourly(\(rate))"
            }
        }
        
        var spouseStr = "nil"
        if let spouse = spouse {
            spouseStr = "\(spouse.firstName) \(spouse.lastName)"
        }
        
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobStr) spouse:\(spouseStr)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person]
    
    public init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse != nil || spouse2.spouse != nil {
            fatalError("One or both spouses already have a spouse")
        }
        
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        
        self.members = [spouse1, spouse2]
    }
    
    public func haveChild(_ child: Person) -> Bool {
        let hasAdultSpouse = members.contains { $0.age >= 21 }
        if !hasAdultSpouse {
            return false
        }
        
        members.append(child)
        return true
    }
    
    public func householdIncome() -> Int {
        var total = 0
        for member in members {
            if let job = member.job {
                total += job.calculateIncome(2000)
            }
        }
        return total
    }
}
