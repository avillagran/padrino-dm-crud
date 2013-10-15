# encoding: utf-8
module VQ
    module DmCrud
        module Helpers
            # def csrf_meta_tags
            #     if protect_against_forgery?
            #         [
            #           tag('meta', :name => 'csrf-param', :content => request_forgery_protection_token),
            #           tag('meta', :name => 'csrf-token', :content => session[:csrf])
            #         ].join("\n").html_safe
            #     end
            # end
              def crud_bar options
                str = %{
                  <ul class='nav nav-tabs not-print'>
                }
                options.each do |i|
                  str << "<li#{' class="active"' unless i[2].blank?}>"

                  str << crud_links(i)

                  str += "</li>"
                end

                  str << %{
                    </ul>  
                  }
                  
                str.html_safe
              end

              def crud_options options

                str  = %{
                  <div class="dropdown">
                    <a class="data-toggle" data-toggle="dropdown">
                      #{options[0]}
                      <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                }
                options[1..-1].each do |i|
                  str << '<li>'
                  str << crud_links( i )
                  str << '</li>'
                end
                str << %{
                    </ul>
                  </div>
                }

                str.html_safe
              end

              def crud_links i
                str = ""
                  if i[0].is_a?(String)
                    str << %{
                      <a href='#{i[1]}'>
                        <span class="glyphicon glyphicon-list"></span>
                        #{i[0]}
                      </a>
                    }
                  elsif i[0] == :add
                    str << %{
                      <a href='#{i[1]}' data-disable-with="Cargando...">
                        <span class="glyphicon glyphicon-plus"></span>
                        Agregar
                      </a>
                    }
                  elsif i[0] == :edit
                    str << %{
                      <a href='#{i[1]}' data-disable-with="Cargando...">
                        <span class="glyphicon glyphicon-edit"></span>
                        Editar
                      </a>
                    }
                  elsif i[0] == :delete
                    str << %{
                      <a href='#{i[1]}' data-confirm="¿Está seguro de querer eliminar?" data-method="delete" data-disable-with="Cargando...">
                        <span class="glyphicon glyphicon-trash"></span>
                        Eliminar
                      </a>
                    }
                  elsif i[0] == :show
                    str << %{
                      <a href='#{i[1]}' data-disable-with="Cargando...">
                        <span class="glyphicon glyphicon-search"></span>
                        Ver
                      </a>
                    }
                  end
                str.html_safe
              end

                # Arma un arreglo para options_for_select a partir de un arreglo de constantes (arr) definidas en una clase (cls)
                def for_select cls, arr, first=""
                fnl = first.blank? ? [] : [ [first, ""] ]
                cls.const_get(arr).each do |i|
                    fnl << [i.to_s.humanize.titleize, cls.const_get(i)]
                end

                fnl
                end
                # Devuelve un hash con el nombre de un valor en particular
                # => Params
                  # => cls : Clase
                  # => arr : Arreglo de constantes
                  # => val : Valor entero 
                def get_name cls, arr, val
                  cls.const_get(arr).each do |i|
                      return i.to_s.humanize.titleize if cls.const_get(i).to_s == val.to_s
                  end
                  return nil
                end

                def value obj, val
                  return "" if obj.nil? || obj.send(val).nil?

                  obj.send(val)
                end

                def get_name_matrix cls, arr, val
                  data = []
                  vl = val + 1000
                  vl = vl.to_s
                  k = 1
                  while k < vl.length do
                      cls.const_get(arr).each do |i|
                          data << i.to_s.humanize.capitalize if vl[k] == '1' && ( 1000+ cls.const_get( i ) ).to_s[k] == '1'
                      end
                      k += 1
                  end
                  return data.join(", ")
                end

                def input form, name, options = {}
                    options[:as]    = :text_field unless options.has_key? :as
                    options[:class] = options[:class].blank? ? 'form-control' : 'form-control '+options[:class]

                    options[:as] = :select if !options[:options].blank?||!options[:collection].blank?
                    options[:as] = name if [:password, :email, :telephone].include?( name )

                    if !options[:collection].blank? && options[:options].blank?
                        options[:options] = options.delete(:collection).map{|x| [x.name, x.id]} if (options[:collection].first.class != Hash)
                    end

                    as                = options.delete :as unless options[:as].blank?

                    label = options.delete :label
                    label = name if label.blank?
                    label = label.to_s.titleize

                    %{
                        <div class='form-group'>
                            #{form.label label}
                            #{
                                str = form.text_field( name, options ) if as.eql? :text_field
                                str = form.text_area( name, options ) if as.eql?(:text_area)||as.eql?(:area)||as.eql?(:text)
                                str = form.select( name, options ) if as.eql? :select
                                str = form.password_field( name, options ) if as.eql? :password
                                str = form.number( name, options ) if as.eql? :number
                                str = form.telephone_field( name, options ) if as.eql? :telephone
                                str = form.email_field( name, options ) if as.eql? :email
                                str = form.check_box( name, options ) if as.eql?( :checkbox )||as.eql?( :boolean )
                                str = form.file_field( name, options ) if ( as.eql?( :file_field ) || as.eql?( :file ) )
                                str
                            }
                        
                        </div>
                    }.html_safe

                end

                def btn txt = 'Save', opts = {}
                  opts = {disable: 'Sending...', icon: 'check', class: 'btn-primary'}.merge opts
                  %{
                    <button class="btn #{opts[:class]}" name="button" type="submit" data-disable-with="#{opts[:disable]}">
                      <span class="glyphicon glyphicon-#{opts[:icon]}"></span>
                      #{txt}
                    </button>
                  }.html_safe
                end

                def controller_is?(value, module_name = nil)
                    status = request.route_obj.controller.downcase == value.to_s.downcase
                    
                    if status && !module_name.nil? && !@module_name.nil?
                      status = module_name.downcase == @module_name.downcase
                    end
                    
                    status
                end
              
                def current_controller_is?(value, extra = true, class_name = 'active')
                    values = value.class == Array ? value : [value]
                    status = false
                    values.each{|x| status = controller_is?(x) if status.eql?(false)}

                    status && extra ? class_name : ''
                end
              
                def action_is?(value)
                    request.route_obj.action.downcase == value.downcase    
                end
              
                def current_action_is?(value)
                    action_is?(value) ? 'current' : ''
                end
              
                def module_is?(value)
                    return false if @module_name.nil?
                    return @module_name.downcase == value.downcase
                end

                def log data = nil
                  if data.class.eql? String
                    logger.info data.bold
                  else
                    logger.info params.inspect.red
                    logger.info "Data: #{data.inspect}".bold.yellow unless data.blank?
                  end
                end
                def log_params; log; end
                def lparams; log; end
        end
    end
end