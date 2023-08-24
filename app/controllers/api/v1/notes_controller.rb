class Api::V1::NotesController < Api::V1::ApiController
  before_action :set_note, only: %i[ update destroy ]

  def index
    @notes = Note.all

    render json: @notes
    ActionCable.server.broadcast('note_channel', { type: 'index', notes: @notes })

  end

  def show
    note = Note.find_by(id: params[:id])

    if note
      render status: 200, json: note.as_json(except: [:created_at, :updated_at])
    else
      render json: { error: "Nota não encontrada" }, status: 404
    end
  end

  def create
    @note = Note.new(note_params)

    if @note.save
      ActionCable.server.broadcast('note_channel', { type: 'create', note: @note })
      render status: 201, json: @note
    else
      render status: 412, json: { errors: @note.errors.full_messages }
    end
  end

  def update
    if @note.update(note_params)
      render json: @note
      ActionCable.server.broadcast('note_channel', { type: 'update', note: @note })
    else
      render status: 412, json: { errors: @note.errors.full_messages }
    end
  end

  def destroy
    if @note.destroy
      render status: 200, json: { message: 'Nota excluída com sucesso' }
    end
  end

  private

    def set_note
      @note = Note.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:body)
    end
end
