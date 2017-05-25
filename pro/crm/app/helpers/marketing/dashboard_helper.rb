module Marketing::DashboardHelper
  # @param year [Integer] => Year to aggregate data.
  #helpers :revenue_by_month, :revenue_by_coordinator


  def zero_safe_guard(num)
    num == 0 ? 1 : num
  end

  def lead_review(num)
    if num > 0
      '<span class="text-success">UP</span> from'.html_safe
    elsif num < 0
      '<span class="text-danger">DOWN</span> from'.html_safe
    else
      "the same as"
    end
  end

  def positive_or_negative?(num)
    if num > 0
      "text-success"
    elsif num < 0
      "text-danger"
    else
      "text-default"
    end
  end

  def surgical_revenue_data
    data = []
    @current_org.sources.each do |src|
      data.push([src.name, src.surgery_revenue])
    end
    data
  end

    def leads_revenue(stage)
      aggregated_data = @current_org.leads.collection.aggregate(
          {'$match' =>
               {
                   :organization_id => @current_org.id,
                   :stage => stage
               }
          },
          {'$project' =>
                  {
                      :stage => '$stage',
                      :cost => '$procedure_cost'
                  }
          },
          {'$group' =>
               {
                     :_id => {:stage => '$stage'},
                     :revenue_count => {'$sum' => '$cost'}
               }
          }
      )

      aggregated_data[0]["revenue_count"]
    end

    def revenue_by_coordinator(year = nil)
      graph_data = []
      months = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
      selection_year = year || Time.now.year
      start_date = Time.new(selection_year, 1, 1)
      end_date = start_date + 1.year

      aggregated_data = @current_org.leads.collection.aggregate(
          {'$match' =>
               {
                   :organization_id => @current_org.id,
                   :stage => 'post_op',
                   :procedure_date => {'$lt' => end_date, '$gte' => start_date}

               }
          },
          {
              '$project' =>
                  {
                      :month => {'$month' => '$procedure_date'},
                      :cost => '$surgery_cost',
                      :coordinator => '$user_id'
                  }
          },
          {'$group' =>
               {
                   :_id => {:month => '$month', :coordinator => '$coordinator'},
                   :revenue_count => {'$sum' => '$cost'}
               }
          },
          {'$group' =>
               {
                   :_id => '$_id.coordinator',
                   :months => {
                       '$push' => {
                           :month => '$_id.month',
                           :count => '$revenue_count'
                       }
                   },
                   :total_count => {'$sum' => '$revenue_count'}
               }
          }
      )

      aggregated_data.each do |data|

        month_wise_data = []
        value = []
        (1..12).each do |index|
          month_wise_data.push(data['months'].select { |val| val['month'] == index }[0])
        end

        (0..11).each do |index|
          value.push(month_wise_data[index].nil? ? nil : month_wise_data[index]['count'])
        end

        user = User.where({:_id => data['_id']}).first
        hash = {
            name: user.nil? ? 'Unnamed' : user.first_name,
            data: value
        }
        graph_data.push(hash)
      end

      final_graph_data = []
      months.each_with_index do |month, index|
        data = {y: month}
          graph_data.each do |user|
            data.merge!(user[:name] => user[:data][index])
          end
        final_graph_data.push(data)
      end

        final_graph_data.to_json
    end

    def consult_to_surgery_by_month(year = nil)

      graph_data = []
      months = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
      selection_year = year || Time.now.year

      start_date = Time.new(selection_year, 1, 1)
      end_date = Time.new(selection_year, 1, 1) + 1.year
      procedure_data = Business::Surgery.collection.aggregate(
          {
              '$match' =>
                  {
                   :organization_id => @current_org.id,
                   :date => {'$lt' => end_date, '$gte' => start_date}
                  }
          },
          {
              '$project' =>
                  {
                      :procedure_month => {'$month' => '$date'}
                  }
          },
          {
              '$group' =>
                  {
                      :_id => '$procedure_month',
                      :count => {'$sum' => 1}
                  }
          },
          {'$sort' => {:_id => 1}}
    )
    consultation_data = Business::Consultation.collection.aggregate(
      {
          '$match' =>
              {
               :organization_id => @current_org.id,
               :date => {'$lt' => end_date, '$gte' => start_date}
              }
      },
      {
          '$project' =>
              {
                  :consultation_month => {'$month' => '$date'}
              }
      },
      {
          '$group' =>
              {
                  :_id => '$consultation_month',
                  :count => {'$sum' => 1}
              }
      },
      {'$sort' => {:_id => 1}}
  )




      months.each_with_index do |month, index|
        data = {y: month}
          month_start = Date.new(selection_year,(index + 1),1)
          month_end = month_start.end_of_month
          consult_count = consultation_data.select { |data| data['_id'] == (index + 1) }.present? ? consultation_data.select { |data| data['_id'] == (index + 1) }[0]["count"] : 0
          procedure_count = procedure_data.select { |data| data['_id'] == (index + 1) }.present? ? procedure_data.select { |data| data['_id'] == (index + 1) }[0]["count"] : 0
          data.merge!("booked_consult" => consult_count)
          data.merge!("booked_surgery" => procedure_count)
          graph_data.push(data)
      end
      graph_data.to_json

    end

    def qualified_leads_per_month(year = nil)
      graph_data = []
      selection_year = year || Time.now.year
      months = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
      start_date = Time.new(selection_year, 1, 1)
      end_date = start_date + 1.year
      aggregated_data = Business::LeadStage.collection.aggregate(
          {'$match' =>
               {
                   :organization_id => @current_org.id,
                   :timestamp => {'$lt' => end_date, '$gte' => start_date},
                   :stage => 'inquiry'
               }
          },
          {
              '$project' =>
                  {
                      :month => {'$month' => '$timestamp'},
                  }
          },
          {
              '$group' =>
                  {
                      :_id => '$month',
                      :count => {'$sum' => 1}
                  }
          },
          {'$sort' => {:_id => 1}}
      )
      (1..12).each do |index|
        month_data = aggregated_data.select { |data| data['_id'] == index }[0]
        graph_data.push([months[index-1], (month_data.nil? ? 0 : month_data['count'])])
      end
      [
          {
              options: [
                  {
                      title: 'Qualified Leads per Month',
                      subTitle: "Year: #{selection_year}",
                      yAxisLabel: 'Qualified Leads',
                      tooltipValueSuffix: ''
                  }
              ]
          },
          {
              series: [{
                           name: 'Qualified Leads',
                           data: graph_data,
                           dataLabels: {
                               enabled: true,
                               rotation: -90,
                               color: '#FFFFFF',
                               align: 'right',
                               y: 10,
                               style: {
                                   fontSize: '13px',
                                   fontFamily: 'Verdana, sans-serif'
                               }
                           }
                       }]
          }
      ]
    end

    def new_leads_per_month(json_data, year = nil)
      graph_data = []
      selection_year = year || 2015
      start_date = Time.new(selection_year, 1, 1)
      end_date = Time.new(Time.now.year, 1, 1) + 1.year
      aggregated_data = @current_org.leads.collection.aggregate(
          {'$match' =>
               {
                   :organization_id => @current_org.id,
                   :timestamp => {'$lt' => end_date, '$gte' => start_date},
                   :stage => 'inquiry'
               }
          },
          {
              '$project' =>
                  {
                      :month => {'$month' => '$timestamp'},
                      :year => {'$year' => '$timestamp'}
                  }
          },
          {
              '$group' =>
                  {
                      :_id => {:month => '$month', :year => '$year'},
                      :count => {'$sum' => 1}
                  }
          },
          {
              '$group' => {
                  :_id => '$_id.year',
                  :months => {
                      '$push' => {
                          :month => '$_id.month',
                          :count => '$count'
                      }
                  },
                  :total_count => {'$sum' => '$count'}
              }
          },
          {'$sort' => {:_id => 1}}
      )

      aggregated_data.each do |data|
        month_wise_data = []
        value = []
        (1..12).each do |index|
          month_wise_data.push(data['months'].select { |val| val['month'] == index }[0])
        end

        (0..11).each do |index|
          if data['_id'].to_s == '2015' && index < 11
            val = nil
          else
            val = month_wise_data[index].nil? ? nil : month_wise_data[index]['count']
          end
          value.push(val)
        end
        hash = {
            name: data['_id'],
            data: value
        }
        graph_data.push(hash)
      end

      dec_data = 355
      graph_data.map { |val| dec_data = val[:data].last if val[:name] == 2015 }
      ## Set the dec 2015 data to static generated list
      json_data[1]['series'].map { |val| (val['data'][11] = dec_data; break;) if val['name'].to_s == '2015' }
      graph_data.reject! { |val| val[:name] == 2015 }

      json_data[1]['series'].push(*graph_data)
      json_data
    end

    def revenue_by_month(year = nil)
      graph_data = []
      months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      selection_year = year || Time.now.year
      last_procedure_lead = Business::Lead.where({:stage => 'booked_surgery'}).order_by(:procedure_date => 'desc').first
      last_procedure_year = (last_procedure_lead.present? && last_procedure_lead.send(:procedure_date).present?) ? last_procedure_lead.send(:procedure_date).year : Time.now.year
      start_date = Time.new(selection_year, 1, 1)
      end_date = Time.new(last_procedure_year, 1, 1) + 1.year
      aggregated_data = @current_org.leads.collection.aggregate(
          {
              '$match' =>
                  {
                    :organization_id => @current_org.id,
                    :procedure_date => {'$lt' => end_date, '$gte' => start_date},
                    :stage_lifecycle =>
                       {
                           '$elemMatch' =>
                               {
                                   :stage => 'booked_surgery',
                                   :timestamp => {'$lt' => end_date, '$gte' => start_date}
                               }
                       }
                  }
          },
          {
              '$project' =>
                  {
                      :year => {'$year' => '$procedure_date'},
                      :month => {'$month' => '$procedure_date'},
                      :cost => '$procedure_cost'
                  }
          },
          {
              '$group' =>
                  {
                      :_id => {:month => '$month', :year => '$year'},
                      :count => {'$sum' => '$cost'}
                  }
          },
          {
              '$group' => {
                  :_id => '$_id.year',
                  :months => {
                      '$push' => {
                          :month => '$_id.month',
                          :count => '$count'
                      }
                  },
                  :total_count => {'$sum' => '$count'}
              }
          },
          {'$sort' => {:_id => -1}}
      )


      final_graph_data = []
      months.each_with_index do |month, index|
        amount = aggregated_data.first["months"].select { |val| val['month'] == (index + 1) }[0]
          data = {m: month}
          if amount.nil?
            data.merge!( "a" => 0)
          else
            data.merge!( "a" => amount["count"])
          end
        final_graph_data.push(data)
      end

      final_graph_data.to_json

    end

    def closing_rate_by_practice_by_month(year = nil)
      graph_data = []
      selection_year = year || Time.now.year
      months = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
      start_date = Time.new(selection_year, 1, 1)
      end_date = start_date + 1.year
      start_date
      aggregated_data = Business::LeadStage.collection.aggregate(
          {'$match' =>
               {
                   :organization_id => @current_org.id,
                   :timestamp => {'$lt' => end_date + 1.month, '$gte' => start_date},
                   :stage => {'$in' => ['booked_surgery', 'booked_consult']}
               }
          },
          {
              '$project' =>
                  {
                      :month => {'$month' => '$timestamp'},
                      :stage => '$stage'
                  }
          },
          {'$group' =>
               {
                   :_id => {:month => '$month'},
                   :count => {'$sum' => 1},
                   :surgery_count => {'$sum' => {'$cond' => [{'$eq' => ["$stage", 'booked_surgery']}, 1, 0]}},
                   :consult_count => {'$sum' => {'$cond' => [{'$eq' => ["$stage", 'booked_consult']}, 1, 0]}},

               }
          },
          {
              '$sort' => {:_id => 1}
          }
      )

      (1..12).each do |index|
        monthdata = aggregated_data.select { |data| data['_id']['month'] == index }
        graph_data.push([months[index-1], (monthdata.present? && monthdata[0].present? ? ((monthdata[0]['surgery_count'].to_f / monthdata[0]['consult_count'].to_f) * 100.0).round(0) : 0)])
        monthdata = nil
      end
      [
          {
              options: [
                  {
                      title: 'Closing Rate by Practice by Month',
                      subTitle: "Year: #{selection_year}",
                      yAxisLabel: 'Total Monthly Revenue',
                      tooltipValueSuffix: ''
                  }
              ]
          },
          {
              series: [{
                           name: 'Closing Rate',
                           data: graph_data,
                           dataLabels: {
                               enabled: true,
                               rotation: -90,
                               color: '#FFFFFF',
                               align: 'right',
                               y: 10,
                               style: {
                                   fontSize: '13px',
                                   fontFamily: 'Verdana, sans-serif'
                               }
                           },
                           tooltip: {
                               pointFormat: 'Close Rate: {point.y}%'
                           }
                       }]
          }
      ]
    end

    ##Closing Rate by Coordinator by Month
    def closing_rate_by_cooardinator_by_month(year = nil)
      graph_data = []
      selection_year = year || Time.now.year
      months = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
      start_date = Time.new(selection_year, 1, 1)
      end_date = start_date + 1.year

      distinct_coordinators = Business::Lead.where(:user_id.ne => nil).distinct(:user_id)
      distinct_coordinators.each do |coordinator_id|
        ##First get the leads of the coordinator
        lead_ids = @current_org.leads.where(:user_id => coordinator_id).all.map(&:_id)
        ## Get the coordinator details
        coordinator = User.where(:id => coordinator_id).first
        ## Second closing_rate_by_cooardinator_by_month of that coordinator leads only
        aggregated_data = Business::LeadStage.collection.aggregate(
            {'$match' =>
                 {
                     :organization_id => @current_org.id,
                     :timestamp => {'$lt' => end_date + 1.month, '$gte' => start_date},
                     :stage => {'$in' => ['booked_surgery', 'booked_consult']},
                     :lead_id => {'$in' => lead_ids}
                 }
            },
            {
                '$project' =>
                    {
                        :month => {'$month' => '$timestamp'},
                        :stage => '$stage'
                    }
            },
            {'$group' =>
                 {
                     :_id => {:month => '$month'},
                     :count => {'$sum' => 1},
                     :surgery_count => {'$sum' => {'$cond' => [{'$eq' => ["$stage", 'booked_surgery']}, 1, 0]}},
                     :consult_count => {'$sum' => {'$cond' => [{'$eq' => ["$stage", 'booked_consult']}, 1, 0]}},

                 }
            },
            {
                '$sort' => {:_id => 1}
            }
        )
        coordinator_monthly_data = []
        (1..12).each do |index|
          monthdata = aggregated_data.select { |data| data['_id']['month'] == index }
          coordinator_monthly_data.push(monthdata.present? && monthdata[0].present? ? ((monthdata[0]['surgery_count'].to_f / monthdata[0]['consult_count'].to_f) * 100.0).round(2) : 0)
          monthdata = nil
        end

        graph_data.push({"name": coordinator.first_name, "data": coordinator_monthly_data})
      end

      ## coordinator loop end
      [
          {
              'options': [
                  {
                      'title': 'Closing Rate by Coordinator by Month',
                      'subTitle': "Year #{selection_year}",
                      'yAxisLabel': 'Total',
                      'tooltipValueSuffix': '%',
                      'xAxisCategories': months,
                      'dataLabels': false,
                      'dataLabelsFormat': '',


                  }
              ]
          },
          {
              series: graph_data
          }
      ]
    end

    def booked_surgeries(coordinator)
      coordinator.leads.where(:procedure_date.gte => Date.today.beginning_of_month, :procedure_date.lte => Date.today.end_of_month).count
    end

    def sales_coordinators(coordinators)
      names = []
        coordinators.each do |coordinator|
          names << coordinator.first_name.titleize.html_safe
        end
      names
    end

    def new_lead_snapshot(start_date, end_date)
      aggregated_data = @current_org.leads.collection.aggregate(
          {
              '$match' =>
                  {
                    :organization_id => @current_org.id,
                    :created_at => {'$lt' => end_date, '$gte' => start_date}
                  }
          },{
              '$group' =>
                  {
                    :_id => "created_at",
                    :count => {'$sum' => 1}
                   }
                }
          )
        aggregated_data[0] ? aggregated_data[0]["count"] : 0
    end

    def consultation_snapshot(start_date, end_date)
      aggregated_data = @current_org.leads.collection.aggregate(
          {
              '$match' =>
                  {
                    :organization_id => @current_org.id,
                    :consultation_date => {'$lt' => end_date, '$gte' => start_date}
                  }
          },
          {
            '$group' =>
              {
                :_id => "consultation_date",
                :count => {'$sum' => 1}
              }
          }
          )
        aggregated_data[0] ? aggregated_data[0]["count"] : 0
    end

    def surgery_snapshot(start_date, end_date)
      aggregated_data = @current_org.leads.collection.aggregate(
          {
            '$match' =>
                {
                  :organization_id => @current_org.id,
                  :procedure_date => {'$lt' => end_date, '$gte' => start_date}
                }
          },
          {
            '$group' =>
              {
                :_id => "procedure_date",
                :count => {'$sum' => 1}
               }
          }
          )
        aggregated_data[0] ? aggregated_data[0]["count"] : 0
    end
    def stage_snapshots(stage, start_date, end_date)
      aggregated_data = @current_org.leads.collection.aggregate(
          {
              '$match' =>
                  {
                    :organization_id => @current_org.id,
                    :stage_lifecycle =>
                       {
                         '$elemMatch' =>
                             {
                                 :stage => stage,
                                 :timestamp => {'$lt' => end_date, '$gte' => start_date}
                             }
                       }
                  }
          },{
              '$group' =>
                  {
                    :_id => stage,
                    :count => {'$sum' => 1}
                   }
                }
          )
        aggregated_data[0] ? aggregated_data[0]["count"] : 0
    end

    def total_monthly_revenue()
      dynamic_start = Date.new(2016,7,1).beginning_of_day
      today = Date.today.end_of_day

      aggregated_data = @current_org.surgeries.collection.aggregate(
          {'$match' =>
                  {
                    :organization_id => @current_org.id,
                    :date => { '$lte' => today, '$gte' => dynamic_start },
                    :completed => true,
                    :cancelled => false
                  }
          },
          {'$project' =>
                  {
                    :cost => '$cost',
                    :year => {'$year' => '$date'},
                    :month => {'$month' => '$date'},
                  }
          },
          {
              '$group' =>
                  {
                      :_id => {:month => '$month', :year => '$year'},
                      :count => {'$sum' => '$cost'}
                  }
          },
          {
              '$group' => {
                  :_id => '$_id.year',
                  :total_count => {'$sum' => '$count'},
                  :months => {
                      '$push' => {
                          :month => '$_id.month',
                          :count => '$count'
                      }
                  }
              }
          },
          {
            '$sort' => {
              :id => 1,
              'months.month' => 1
            }
          }
      )
      dynamic_data_for_series = []
      aggregated_data.reverse.each do |year|
        if year["_id"] == 2016

          data = [ 477200, 471889, 602300, 484900, 409050, 501861,0,0,0,0,0,0 ]
          12.times do |n|
            year["months"].each do |month|
              if month["month"] == n + 1 && n > 5
                data[n] = month["count"]
              end
            end
          end

        else

          data = [0,0,0,0,0,0,0,0,0,0,0,0]
          12.times do |n|
            year["months"].each do |month|
              if month["month"] == n + 1
                data[n] = month["count"]
              end
            end
          end

        end
        dynamic_data_for_series.push({name: "#{year["_id"]} Revenue", data: data, sum: data.inject('+')})
      end
      if @current_org.company_name == "4Beauty"
        series = [
                  {
                    name: "2012 Revenue",
                    data: [ 302900, 387300, 296100, 327250, 278800, 316150, 442500, 505100, 355100, 334350, 391930, 289850 ],
                    sum: 4227330
                  },
                  {
                    name: "2013 Revenue",
                    data: [ 463950, 318950, 375350, 475000, 409000, 538850, 458750, 421200, 331850, 326750, 306100, 324600 ],
                    sum: 4750350
                  },
                  {
                    name: "2014 Revenue",
                    data: [ 394550, 293950, 472000, 477950, 450600, 510500, 601050, 381600, 340350, 383850, 333850, 514800 ],
                    sum: 5155050
                  },
                  {
                    name: "2015 Revenue",
                    data: [ 440250, 469150, 551000, 514950, 399800, 444250, 456000, 497850, 448150, 440170, 393900, 381850 ],
                    sum: 5437320
                  }
                 ]
       else
         series = []
       end

        dynamic_data_for_series.each do |each_years_data|
          series.push(each_years_data)
        end
        series.to_json.html_safe


    end

    def total_monthly_leads()
      dynamic_start = Date.new(2016,7,1)
      today = Date.today

      aggregated_data = @current_org.leads.collection.aggregate(
          {
            '$match' =>
                  {
                    :organization_id => @current_org.id,
                    :created_at => { '$lt' => today, '$gte' => dynamic_start }
                  }
          },
          {
            '$project' =>
                  {
                    :year => {'$year' => '$created_at'},
                    :month => {'$month' => '$created_at'}
                  }
          },
          {
              '$group' =>
                  {
                      :_id => {:month => '$month', :year => '$year'},
                      :count => {'$sum' => 1}
                  }
          },
          {
              '$group' => {
                  :_id => '$_id.year',
                  :total_count => {'$sum' => '$count'},
                  :months => {
                      '$push' => {
                          :month => '$_id.month',
                          :count => '$count'
                      }
                  }
              }
          },
          {
            '$sort' => {
              :id => 1,
              'months.month' => 1
            }
          }
      )

      dynamic_data_for_series = []
      aggregated_data.reverse.each do |year|
        if year["_id"] == 2016

          data = [ 592, 452, 528, 679, 794, 594, 530,0,0,0,0,0 ]
          12.times do |n|
            year["months"].each do |month|
              if month["month"] == n + 1 && n > 6
                data[n] = month["count"]
              end
            end
          end

        else

          data = [0,0,0,0,0,0,0,0,0,0,0,0]
          12.times do |n|
            year["months"].each do |month|
              if month["month"] == n + 1
                data[n] = month["count"]
              end
            end
          end

        end
        dynamic_data_for_series.push({name: "#{year["_id"]}", data: data})
      end

      if @current_org.company_name == "4Beauty"
        series = [
                  {
                    name: "2014",
                    data: [ 338, 345, 341, 301, 351, 458, 308, 258, 290, 278, 181, 114 ]
                  },
                  {
                    name: "2015",
                    data: [ 374, 420, 341, 216, 364, 336, 431, 460, 425, 690, 441, 393 ]
                  }
                 ]
      else
        series = []
      end


        dynamic_data_for_series.each do |each_years_data|
          series.push(each_years_data)
        end
        series.to_json.html_safe
    end

    def running_total()
      dynamic_start = Date.new(2016,7,1)
      today = Date.today

      aggregated_data = @current_org.surgeries.collection.aggregate(
          {
            '$match' =>
                  {
                    :organization_id => @current_org.id,
                    :date => { '$lt' => today, '$gte' => dynamic_start },
                    :completed => true
                  }
          },
          {
            '$project' =>
                  {
                    :year => {'$year' => '$date'},
                    :month => {'$month' => '$date'},
                    :cost => '$cost'
                  }
          },
          {
              '$group' =>
                  {
                      :_id => {:month => '$month', :year => '$year'},
                      :count => {'$sum' => '$cost'}
                  }
          },
          {
              '$group' => {
                  :_id => '$_id.year',
                  :total_count => {'$sum' => '$count'},
                  :months => {
                      '$push' => {
                          :month => '$_id.month',
                          :count => '$count'
                      }
                  }
              }
          },
          {
            '$sort' => {
              :id => 1,
              'months.month' => 1
            }
          }
      )

      dynamic_data_for_series = []
      aggregated_data.reverse.each do |year|
        if year["_id"] == 2016

          data = [ 477200, 949089, 1551389, 2036289, 2445339, 2947200,0,0,0,0,0,0 ]
          12.times do |n|
            year["months"].each do |month|
              if month["month"] == n + 1 && n > 5
                data[n] = data[n - 1] + month["count"]
              end
            end
          end

        else

          data = [0,0,0,0,0,0,0,0,0,0,0,0]
          12.times do |n|
            year["months"].each do |month|
              if month["month"] == n + 1
                data[n] = data[n - 1] + month["count"]
              end
            end
          end

        end
        data.delete_if {|number| number == 0 }
        dynamic_data_for_series.push({name: "#{year["_id"]}", data: data})
      end
      if @current_org.company_name == "4Beauty"
        series =  [
                    {
                      name: '2012',
                      data: [302900, 690200, 986300, 1313550, 1592350, 1908500, 2351000, 2856100, 3211200, 3545550, 3937480, 4227330]
                    },
                    {
                      name: '2013',
                      data: [463950, 782900, 1158250, 1633250, 2042250, 2581100, 3039850, 3461050, 3792900, 4119650, 4425750, 4750350]
                    },
                    {
                      name: '2014',
                      data: [394550, 688500, 1160500, 1638450, 2089050, 2599550, 3200600, 3582200, 3922550, 4306400, 4640250, 5155050]
                    },
                    {
                      name: '2015',
                      data: [440250, 909400, 1460400, 1975350, 2375150, 2819400, 3275400, 3773250, 4221400, 4661570, 5055470, 5437320]
                    }
                  ]
      else
        series = []
      end


        dynamic_data_for_series.each do |each_years_data|
          series.push(each_years_data)
        end
        series.to_json.html_safe
    end

  end
