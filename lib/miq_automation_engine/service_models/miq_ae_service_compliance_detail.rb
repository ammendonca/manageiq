module MiqAeMethodService
  class MiqAeServiceComplianceDetail < MiqAeServiceModelBase
    expose :compliance, :association => true
    expose :condition, :association => true
    expose :miq_policy, :association => true
  end
end
