-- Generate Exam using cusrsor
CREATE PROCEDURE Exam_Generator
	@Course_ID INT,
    @NumMCQ INT= 5,
    @NumTF INT = 5
AS
BEGIN
    DECLARE @Exam_ID INT
	    BEGIN TRY
        IF (@Course_ID IS NULL OR @NumMCQ IS NULL OR @NumTF IS NULL)
            RAISERROR('Course, Number Of MCQ Questions, Number Of T/F Questions are required', 16, 1)
        ELSE
            -- Insert a new exam into the exam table and get the generated ID
			INSERT INTO Exam
			Values (@NumMCQ+@NumTF,@Course_ID)
		Set @exam_ID = SCOPE_IDENTITY()
	-- MCQ Questions
	Insert Into ExamQuestions (Exam_ID,Ques_ID)
	Select @exam_ID , MCQ_Ques_ID.Ques_id
	From (
			Select Top (@NumMCQ) Ques_id
			From Question
			Where Course_ID = @Course_ID AND Ques_Type = 'MCQ'
			Order By NEWID()
		 ) MCQ_Ques_ID

	-- T/F Questions
	Insert Into ExamQuestions (Exam_ID,Ques_ID)
	Select @exam_ID , TF_Ques_ID.Ques_id
	From (
			Select Top (@NumTF) Ques_id
			From Question
			Where Course_ID = @Course_ID AND Ques_Type = 'T/F'
			Order By NEWID()
		 ) TF_Ques_ID

	-- For Display Exam 
	Declare @Cur_Ques int;

		Declare Ques_Cur Cursor
			For Select Ques_ID
				From ExamQuestions
				Where Exam_ID = @Exam_ID;

		Open Ques_Cur;

		Fetch Next From Ques_Cur 
		Into @Cur_Ques;

		While @@FETCH_STATUS = 0 
			Begin 
				Select Concat ('- ',@exam_ID,' - ',Ques_id,' - ',Ques) AS 'Question' 
				From Question
				Where Ques_ID = @Cur_Ques
				Union
				Select Choice
				From Question_Choice
				Where Ques_ID = @Cur_Ques
				
				FETCH NEXT FROM Ques_Cur INTO 
				@Cur_Ques;
			End;

		Close Ques_Cur;
		Deallocate Ques_Cur;



    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
