module BeforeHook
  # The `before` hook for rake tasks.
  # The code was taken from https://github.com/guillermo/rake-hooks/blob/master/lib/rake/hooks.rb#L2
  def before_rake_task(*task_names, &new_task)
    task_names.each do |task_name|
      old_task = Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
      return unless old_task

      desc old_task.full_comment
      task task_name => old_task.prerequisites do
        begin
          new_task.call
        rescue LoadError
          #empty
        end
        old_task.invoke
      end
    end
  end
end
