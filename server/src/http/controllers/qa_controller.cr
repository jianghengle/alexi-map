require "./controller_base"

module AlexiServer
  module HttpAPI
    module QAController
      include AlexiServer::HttpAPI::ControllerBase
      extend self

      def get_questions(ctx)
        begin
          questions = Question.get_all_questions
          answers = Answer.get_all_answers
          user_ids = [] of (Int8 | Int16 | Int32 | Int64 | String | Nil)
          questions.each do |q|
            user_ids << q.user_id unless q.user_id.nil?
          end
          answers.each do |a|
            user_ids << a.user_id unless a.user_id.nil?
          end
          users_json = User.get_users_by_ids_json(user_ids)
          questions_json = to_json_array(questions)
          answers_json = to_json_array(answers)
          "{\"questions\":#{questions_json}, \"answers\":#{answers_json}, \"users\": #{users_json}}"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_question(ctx)
        begin
          subject = get_param!(ctx, "subject")
          content = get_param!(ctx, "content")
          user = get_user(ctx)
          question = Question.create_question(subject, content, user)
          user_json = "null"
          unless user.nil?
            name = user.first_name.to_s + "." + user.last_name.to_s
            user_json = "{\"id\": #{user.id}, \"name\": #{name.to_json}}"
          end
          "{\"question\": #{question.to_json}, \"user\": #{user_json}}"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_question(ctx)
        begin
          question_id = get_param!(ctx, "questionId")
          user = get_user!(ctx)
          raise "Permission denied" unless user.role.to_s == "Admin"
          Question.delete_question(question_id)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_answer(ctx)
        begin
          user = get_user!(ctx)
          question_id = get_param!(ctx, "questionId").to_i
          content = get_param!(ctx, "content")
          answer = Answer.create_answer(question_id, content, user)
          name = user.first_name.to_s + "." + user.last_name.to_s
          user_json = "{\"id\": #{user.id}, \"name\": #{name.to_json}}"
          "{\"answer\": #{answer.to_json}, \"user\": #{user_json}}"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_answer(ctx)
        begin
          user = get_user!(ctx)
          answer_id = get_param!(ctx, "answerId").to_i
          content = get_param!(ctx, "content")
          Answer.update_answer(answer_id, content, user)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_answer(ctx)
        begin
          user = get_user!(ctx)
          answer_id = get_param!(ctx, "answerId").to_i
          Answer.delete_answer(answer_id, user)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
