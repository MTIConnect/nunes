# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :posts, only: %i[index new]
  end

  resources :posts, only: :index

  get '/some-data',     to: 'posts#some_data'
  get '/some-file',     to: 'posts#some_file'
  get '/some-redirect', to: 'posts#some_redirect'
  get '/some-boom',     to: 'posts#some_boom'
end
