Ooorest::Engine.routes.draw do
  controller "rest" do

    root_actions = [["/", :dashboard, :dashboard, [:get]]]
    collection_actions = [["/", :index, :index, [:get]],
                          ["/new", :new, :new, [:get]],
                          ["/", :create, :create, [:post]],
                          ["/export", :export, :export, [:get, :post]],
                          ["/bulk_delete", :bulk_delete, :bulk_delete, [:post, :delete]]]
    member_actions = [["/", :show, :show, [:get]],
                      ["/edit", :edit, :edit, [:get]],
                      ["/update", :update, :update, [:patch]],
                      ["/", :destroy, :destroy, [:delete]],
                      ["/show_in_app", :show_in_app, :show_in_app, [:get]]]

    root_actions.each { |action| match action[0], :action => action[1], :as => action[2], :via => action[3] }
    scope ":model_name" do
      collection_actions.each { |action| match action[0], :action => action[1], :as => action[2], :via => action[3] }
      post "/model_action", :action => :model_action, :as => "model_action"
      scope ":id" do
        member_actions.each { |action| match action[0], :action => action[1], :as => action[2], :via => action[3] }
        post  "/bulk_action", :action => :bulk_action, :as => "bulk_action"
      end
    end
  end
end
