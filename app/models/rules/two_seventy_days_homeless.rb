class Rules::TwoSeventyDaysHomeless < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if Client.column_names.include?(:days_homeless.to_s)
      if requirement.positive
        where = c_t[:days_homeless].gteq(270)
      else
        where = c_t[:days_homeless].lt(270)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.days_homeless missing. Cannot check clients against #{self.class}.")
    end
  end
end
