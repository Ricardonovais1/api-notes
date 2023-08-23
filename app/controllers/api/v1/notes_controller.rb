class Api::V1::NotesController < Api::V1::ApiController
  before_action :set_note, only: %i[ update destroy ]

  # GET /notes
  def index
    @notes = Note.all

    render json: @notes
  end

  # GET /notes/1
  def show
    note = Note.find_by(id: params[:id])

    if note
      render status: 200, json: note.as_json(except: [:created_at, :updated_at])
    else
      render json: { error: "Nota não encontrada" }, status: 404
    end
  end

  # POST /notes
  def create
    @note = Note.new(note_params)

    if @note.save
      render status: 201, json: @note
    else
      render status: 412, json: { errors: @note.errors.full_messages }
    end
  end

  # PATCH/PUT /notes/1
  def update
    if @note.update(note_params)
      render json: @note
    else
      render status: 412, json: { errors: @note.errors.full_messages }
    end
  end

  # DELETE /notes/1
  def destroy
    if @note.destroy
      render status: 200, json: { message: 'Nota excluída com sucesso' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.require(:note).permit(:body)
    end
end
