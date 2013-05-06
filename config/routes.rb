Ooorest::Engine.routes.draw do
  controller "rest" do

    root_actions = [["/", :dashboard, :dashboard, [:get]]]
    collection_actions = [["/", :index, :index, [:get, :post]],
                          ["/new", :new, :new, [:get, :post]],
                          ["/export", :export, :export, [:get, :post]],
                          ["/bulk_delete", :bulk_delete, :bulk_delete, [:post, :delete]]]
    member_actions = [["/", :show, :show, [:get]],
                      ["/edit", :edit, :edit, [:get, :put]],
                      ["/delete", :delete, :delete, [:get, :delete]],
                      ["/show_in_app", :show_in_app, :show_in_app, [:get]]]

    root_actions.each { |action| match action[0], :to => action[1], :as => action[2], :via => action[3] }
    scope ":model_name" do
      collection_actions.each { |action| match action[0], :to => action[1], :as => action[2], :via => action[3] }
      post  "/bulk_action", :to => :bulk_action, :as => "bulk_action"
      scope ":id" do
        member_actions.each { |action| match action[0], :to => action[1], :as => action[2], :via => action[3] }
      end
    end
  end
end
