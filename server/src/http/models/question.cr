module AlexiServer
  module HttpAPI
    class Question < Crecto::Model
      schema "questions" do
        field :user_id, Int32
        field :subject, String
        field :content, String
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          unless @user_id.nil?
            str << "\"userId\":" << @user_id << ","
          end
          str << "\"subject\":" << @subject.to_json << ","
          str << "\"content\":" << @content.to_json << ","
          str << "\"created\":" << @created_at.as(Time).to_unix
          str << "}"
        end
        result
      end

      def self.get_all_questions
        questions = Repo.all(Question)
        return [] of Question if questions.nil?
        questions.as(Array(Question))
      end

      def self.create_question(subject, content, user = nil)
        question = Question.new
        question.subject = subject
        question.content = content
        question.user_id = user.id unless user.nil?
        changeset = Repo.insert(question)
        raise changeset.errors.to_s unless changeset.valid?
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            id = change[:id].as(Int32)
            question = Repo.get(Question, id)
            raise "Cannot find the new question" if question.nil?
            return question
          end
        end
        return question
      end

      def self.delete_question(question_id)
        query = Query.where(question_id: question_id)
        Repo.delete_all(Answer, query)

        query = Query.where(id: question_id)
        Repo.delete_all(Question, query)
      end
    end
  end
end
