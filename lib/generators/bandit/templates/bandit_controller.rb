class BanditController < ApplicationController                                                                                                                                                   
  layout 'bandit'

  def index
    @experiments = Bandit.experiments
  end

  def show
    @experiment = Bandit.get_experiment params[:id].intern
    respond_to do |format|
      format.html
      format.csv { render :text => experiment_csv(@experiment) }
    end
  end

  private
  def experiment_csv(experiment)
    rows = []
    experiment.alternatives.each { |alt|
      start = experiment.alternative_start(alt)
      next if start.nil?
      start.date.upto(Date.today) { |d|
        pcount = Bandit::DateHour.date_inject(d, 0) { |sum,dh| sum + experiment.participant_count(alt, dh) }
        ccount = Bandit::DateHour.date_inject(d, 0) { |sum,dh| sum + experiment.conversion_count(alt, dh) }
        rows << [ alt, d.year, d.month, d.day, pcount, ccount ].join("\t")
      }
    }
    rows.join("\n")
  end
end  
