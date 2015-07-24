require_relative 'dm-crud-helpers'

module VQ
    module DmCrud
        @base    = nil
        @model   = nil
        @map     = nil
        @only    = nil
        @success = nil
        @error   = nil
        @except  = nil


        def self.registered(app)
            logger.info "REGISTER"
            app.helpers VQ::DmCrud::Helpers
        end

        def self.init base, options = {}
            @base    = base
            @model   = options[:model]
            @map     = options[:map]
            @only    = options[:only].blank? ? [:index, :show, :new, :create, :edit, :update, :destroy] : ( options[:only].class == Array ? options[:only] : [options[:only]] )
            @except  = options[:except].blank? ? [] : (options[:except].class == Array ? options[:except] : [options[:except]])
            @success = options[:success].blank? ? 'Successfully updated' : options[:success]
            @error   = options[:error].blank? ? 'Problems' : options[:error]

            set_config
        end

        private

        def self.set_config

            model         = @model.blank? ? nil : @model.to_s
            unless model.blank?
                singular_name = model
                class_name    = singular_name.camelize
                plural_name   = singular_name.pluralize
            end
            opts = {}
            opts[:map] = @map unless @map.blank?



            lambda {

                @base.get :index, opts do
                    eval %(
                        @items = #{class_name}.all
                    ) unless model.nil?

                    render "#{request.route_obj.controller}/index"
                end if @only.include?( :index ) && !@except.include?( :index )

                @base.get :new, opts[:map].blank? ? opts : opts.merge(map: opts[:map]+"/new") do
                    logger.info "Class name: #{class_name}".red
                    eval %(
                        @item = #{class_name}.new
                    ) unless model.nil?
                    logger.info "Item: #{@item} Model: #{model} Ruta: #{request.route_obj.controller}/new".blue
                    render "#{request.route_obj.controller}/new"
                end if @only.include?( :new ) && !@except.include?( :new )

                @base.get :show, opts.merge({with: :id}) do
                    logger.info "SHOW".red
                    eval %(
                        @item = #{class_name}.get params[:id]
                    ) unless model.nil?
                    render "#{request.route_obj.controller}/show"
                end if @only.include?( :show ) && !@except.include?( :show )



                @base.post :create, opts do
                    eval %(
                        @item = #{class_name}.new(params[:#{singular_name}])

                        # ok = true#before_create
                        # return ok unless ok === true

                        if @item.valid? && @item.save
                            flash[:notice] = t(:success)
                            #successful_update
                        else
                            flash[:error] = t(:error)
                            #failed_update
                        end
                    ) unless model.nil?

                    redirect_to url(request.route_obj.controller.to_sym, :index)
                end if @only.include?( :create ) && !@except.include?( :create )

                @base.get :edit, opts[:map].blank? ? opts.merge(with: :id) : opts.merge(map: opts[:map]+"/edit", with: :id) do
                    eval %(
                        @item = #{class_name}.get params[:id]
                    ) unless model.nil?

                    render "#{request.route_obj.controller}/edit"
                end if ( @only.include?( :edit ) ) && !@except.include?( :edit )

                @base.post :update, opts.merge({with: :id}) do
                    eval %(
                        @item = #{class_name}.get params[:id]

                        # ok = true #before_update
                        # return ok unless ok === true

                        if @item.update(params[:#{singular_name}])
                            flash[:notice] = t(:success)
                            #successful_update
                        else
                            flash[:error] = t(:error)
                            logger.info ("[UPDATE::ERROR] "+@item.errors.inspect).red.bold
                            #failed_update
                        end

                    ) unless model.nil?
                    redirect_to url(request.route_obj.controller.to_sym, :index)
                end if ( @only.include?(:update) ) && !@except.include?( :update )

                @base.delete :destroy, opts.merge({with: :id}) do
                    eval %(
                        @item = #{class_name}.get params[:id]
                        # ok = true#before_destroy
                        # return ok unless ok === true

                        if @item.destroy
                            flash[:notice] = t(:success_delete)
                        else
                            flash[:error] = t(:error_delete)
                        end
                    ) unless model.nil?
                    redirect_to url(request.route_obj.controller.to_sym, :index)
                end if  @only.include?( :destroy ) && !@except.include?( :destroy )
            }.call
        end



    end
end
