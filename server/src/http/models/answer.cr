module AlexiServer
  module HttpAPI
    class Answer < Crecto::Model
      schema "answers" do
        field :user_id, Int32
        field :question_id, Int32
        field :content, String
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"questionId\":" << @question_id << ","
          str << "\"content\":" << @content.to_json << ","
          str << "\"created\":" << @created_at.as(Time).epoch
          str << "}"
        end
        result
      end

      def self.get_all_answers
        answers = Repo.all(Answer)
        return [] of Answer if answers.nil?
        answers.as(Array(Answer))
      end

      def self.create_answer(question_id, content, user)
        answer = Answer.new
        answer.question_id = question_id
        answer.content = content
        answer.user_id = user.id

        changeset = Repo.insert(answer)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_answer(answer_id, content, user)
        answer = Repo.get(Answer, answer_id)
        raise "Cannot find the answer" if answer.nil?
        answer = answer.as(Answer)
        raise "Permission denied" unless answer.user_id == user.id

        answer.content = content
        changeset = Repo.update(answer)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.delete_answer(answer_id, user)
        answer = Repo.get(Answer, answer_id)
        raise "Cannot find the answer" if answer.nil?
        answer = answer.as(Answer)
        raise "Permission denied" unless answer.user_id == user.id

        changeset = Repo.delete(answer)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.to_json_array(answers)
        ss = answers.map { |a| a.to_json }
        "[#{ss.join(",")}]"
      end
    end
  end
end
