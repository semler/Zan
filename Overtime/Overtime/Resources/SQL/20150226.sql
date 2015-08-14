ALTER TABLE time ADD COLUMN memo_txt TEXT;
ALTER TABLE time ADD COLUMN start_type TEXT;
ALTER TABLE time ADD COLUMN end_type TEXT;
ALTER TABLE time ADD COLUMN start_latitude TEXT;
ALTER TABLE time ADD COLUMN start_longitude TEXT;
ALTER TABLE time ADD COLUMN end_latitude TEXT;
ALTER TABLE time ADD COLUMN end_longitude TEXT;
CREATE TABLE "task" ("pid" integer PRIMARY KEY AUTOINCREMENT, "tid" text, "task_id" text, "task_tag" text, "task_title" text, "task_type" text, "task_days" text, "campaign_flag" text, "task_date" text, "capable_times" text, "finished_times" text, "finished_days" text, "create_date" text, "update_date" text, "delete_flag" text);