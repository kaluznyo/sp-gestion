# Controller generated by Typus, use it to extend admin functionality.
class Admin::StatisticsController < TypusController

  def index
    @nb_nl_inactive = Newsletter.inactive.count
    @nb_nl_to_invite = Newsletter.to_invite.count
    @nb_nl_invited = Newsletter.invited.count
    
    @nb_bc_unused = BetaCode.unused.count
    @nb_bc_inactive = BetaCode.inactive.count
    @nb_bc_used = BetaCode.used.count
  end

end
