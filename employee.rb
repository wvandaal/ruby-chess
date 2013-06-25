class Employee
  attr_reader :name, :title, :salary, :boss
  def initialize(name, title, salary, boss)
    @name = name,
    @title = title,
    @salary = salary,
    @boss = boss
  end

  def calculate_bonus(multiplier)
    bonus = self.salary * multiplier
  end
end

class Manager < Employee
  attr_accessor :employees_under
  def initialize(name, title, salary, boss, employees_under)
    super(name, title, salary, boss)
    @employees_under = employees_under
  end

  def assign_employee(employee)
    employees_under << employee
  end

  def calculate_bonus(multiplier)
    sum = 0
    employees_under.each {|employee| sum += employee.salary}
    sum * multiplier
  end

end