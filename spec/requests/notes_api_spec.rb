require 'rails_helper'

describe 'Notes API' do
  context 'GET /api/v1/notes/1' do
    it 'sucesso' do
      note = Note.create!(body: 'Fazer ginástica às 9h')

      get "/api/v1/notes/#{note.id}"

      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response["body"]).to eq 'Fazer ginástica às 9h'
      expect(json_response.keys).not_to include('created_at')
      expect(json_response.keys).not_to include('updated_at')
    end

    it 'falso se note não foi encontrada' do
      get "/api/v1/notes/99999999"
      expect(response.status). to eq 404
    end
  end

  context 'GET /api/v1/notes' do
    it 'sucesso e ordenado por nome em ordem de criação' do
      note_1 = Note.create!(body: 'Fazer ginástica às 9h')

      note_2 = Note.create!(body: 'Pagar conta de luz')

      get '/api/v1/notes'

      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response.class).to eq Array
      expect(json_response.length).to eq 2
      expect(json_response[0]["body"]).to eq "Fazer ginástica às 9h"
      expect(json_response[1]["body"]).to eq "Pagar conta de luz"
    end

    it 'retornar vazio se não houver nota' do
      get '/api/v1/notes'

      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response).to eq []
    end

    it 'e raise erro interno' do
      allow(Note).to receive(:all).and_raise(ActiveRecord::QueryCanceled)

      note_1 = Note.create!(body: 'Fazer ginástica às 9h')

      note_2 = Note.create!(body: 'Pagar conta de luz')

      get '/api/v1/notes'

      expect(response.status).to eq 500
    end
  end

  context 'POST /api/v1/notes' do
    it 'com sucesso' do
      note_hash = { note: { body: 'Fazer ginástica às 9h' } }

      post '/api/v1/notes', params: note_hash

      expect(response.status).to eq 201
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response["body"]).to eq 'Fazer ginástica às 9h'
    end

    it 'Falha se parâmetros não forem completos' do
      # Payload:
      note_params = { note: {body: ''}}

      post '/api/v1/notes', params: note_params

      expect(response).to have_http_status(412)
      expect(response.body).to include "Body can't be blank"
    end

    it 'falha se houver um erro interno' do
      #mock => Rspec respondendo com um erro proposital para fins de teste:
      allow(Note).to receive(:new).and_raise(ActiveRecord::ActiveRecordError)
      note_hash = { note: {body: 'Levar crianças para a escola'}}

      post '/api/v1/notes', params: note_hash

      expect(response.status).to eq 500
    end
  end

  context 'PATCH /api/v1/notas/1' do
    it 'edita o nome da nota com sucesso' do
      note_original = { note: {body: 'Levar crianças para a escola'} }

      post '/api/v1/notes', params: note_original

      original_note_id = JSON.parse(response.body)["id"]

      patch "/api/v1/notes/#{original_note_id}", params: { note: { body: 'Levar crianças para a escola às 12:20'} }

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["body"]).to eq 'Levar crianças para a escola às 12:20'
    end

    it 'falha quando ocorre uma edição com valor em branco' do
      note_original = { note: {body: 'Levar crianças para a escola'} }

      post '/api/v1/notes', params: note_original
      original_note_id = JSON.parse(response.body)["id"]

      patch "/api/v1/notes/#{original_note_id}", params: { note: { body: '' } }

      expect(response.status).to eq 412
      expect(response.body).to include "Body can't be blank"
    end

    it 'falha se houver um erro interno' do
      # Arrange
      # allow_any_instance_of(Warehouse).to receive(:update).and_raise(ActiveRecord::ActiveRecordError)
      note = instance_double(Note)
      allow(Note).to receive(:find).and_return(note)
      allow(note).to receive(:update).and_raise(ActiveRecord::ActiveRecordError)
      note_original = { note: { body: 'Levar crianças pra escola' } }

      post '/api/v1/notes', params: note_original
      original_note_id = JSON.parse(response.body)["id"]

      patch "/api/v1/notes/#{original_note_id}", params: { note: { body: 'Levar crianças pra escola às 12:20'} }

      expect(response.status).to eq 500
    end
  end

  context 'DELETE /api/v1/notes/1' do
    it 'usuário deleta nota com sucesso' do
      note_original = { note: {body: 'Levar crianças pra escola'} }

      post '/api/v1/notes', params: note_original

      original_note_id = JSON.parse(response.body)["id"]

      delete "/api/v1/notes/#{original_note_id}"

      expect(response.status).to eq 200
      expect(response.body).to include 'Nota excluída com sucesso'
    end

    it 'falha com erro do servidor' do
      note = instance_double(Note)
      allow(Note).to receive(:find).and_return(note)
      allow(note).to receive(:destroy).and_raise(ActiveRecord::ActiveRecordError)

      note_original = { note: {body: 'Levar crianças pra escola'} }

      post '/api/v1/notes', params: note_original

      original_note_id = JSON.parse(response.body)["id"]

      delete "/api/v1/notes/#{original_note_id}"

      expect(response.status).to eq 500
    end
  end
end