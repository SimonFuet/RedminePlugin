class RttControllerController < ApplicationController

  def index
    current_user = User.current
    @user_rtts = Rtt.where(user_id: current_user.id).order(:month)
  end

  def create
    
    current_user = User.current
    
    all_months_reports = Rtt.where(user_id: current_user.id).order(:year, :month)
    
    year = all_months_reports.last.year
    month = all_months_reports.last.month + 1
    if month == 13
      year += 1
      month = 1
    end
    
    if Date.current < Date.civil(year, month, -1)
      redirect_to '/rtt_controller'
      return
    end
    
    acquired_hours = 0
    used_hours = 0
    time_entries = TimeEntry.where(user_id: current_user.id, tyear: year, tmonth: month)
    (Date.new(year, month, 1)..Date.civil(year, month, -1)).each do |day_date|
      
      due_hours = 0
      if !day_date.saturday? && !day_date.sunday?
        due_hours = 7
      end
      
      day_hours = time_entries.where(spent_on: day_date).sum(:hours).to_f - due_hours
      if day_hours > 0
        acquired_hours += day_hours
      else
        used_hours += day_hours
      end
      
    end
    
    # Substract used_hours from positive months
    non_dispatched_used_hours = -used_hours
    all_months_reports = Rtt.where(user_id: current_user.id, extra_hours_left: 0..1000000).order(:year, :month)
    all_months_reports.each do |cur_month|
      if cur_month.extra_hours_left > non_dispatched_used_hours
        cur_month.update extra_hours_left: (cur_month.extra_hours_left - non_dispatched_used_hours)
        non_dispatched_used_hours = 0
        break
      else
        non_dispatched_used_hours -= cur_month.extra_hours_left
        cur_month.update extra_hours_left: 0
      end
    end
    
    # Dispatch extra hours to negative months
    non_dispatched_acquired_hours = acquired_hours
    all_months_reports = Rtt.where(user_id: current_user.id, extra_hours_left: -1000000..0).order(:year, :month)
    all_months_reports.each do |cur_month|
      if -cur_month.extra_hours_left > non_dispatched_acquired_hours
        cur_month.update extra_hours_left: (cur_month.extra_hours_left + non_dispatched_acquired_hours)
        non_dispatched_acquired_hours = 0
        break
      else
        non_dispatched_acquired_hours += cur_month.extra_hours_left
        cur_month.update extra_hours_left: 0
      end
    end
    
    # TODO test everything
    
    Rtt.create(
      :user_id => current_user.id,
      :year => year,
      :month => month,
      :extra_hours_acquired => acquired_hours,
      :extra_hours_used => used_hours,
      :extra_hours_left => non_dispatched_acquired_hours - non_dispatched_used_hours)
    
    redirect_to '/rtt_controller'
  end
end
