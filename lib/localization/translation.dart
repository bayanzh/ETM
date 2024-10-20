import 'package:get/get.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        "ar": {
          "AM": "صباحاً",
          "PM": "مساءً",
          "All": "الكل",
          "Arabic": "عربي",
          "English": "انجليزي",
          "Date": "التاريخ",
          "Cancel": "إلغاء",
          "Delete": "حذف",
          "Agree": "موافق",
          "Confirm": "تأكيد",
          "Next": "التالي",
          "Close": "إغلاق",
          "Save": "حفظ",
          "Edit": "تعديل",
          "Skip": "تخطي",
          "Exit": "خروج",
          "Loading...": "تحميل...",
          "Done Successfully!": "تم بنجاح",
          "Write here": "اكتب هنا",
          "Confirmation message": "رسالة تأكيد",
          "Confirm deletion!": "تأكيد الحذف!",
          "Are you sure you want to log out?": "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          "loading...": "جاري التحميل...",
          "No data found": "لم يتم العثور على بيانات",
          "Alert": "تحذير",
          "Change": "تغيير",
          "": "",
          "You must be logged in.": "يجب عليك تسجيل الدخول.",
          "Are you sure you want to stop the quiz?\nNote: When you return again, the quiz will be completed from the question you stopped at.": "هل أنت متأكد من أنك تريد إيقاف الاختبار؟\nملاحظة: عند عودتك مرة أخرى، سيتم إكمال الاختبار من السؤال الذي توقفت عنده.",
          "Unexpected error!, try again.": "خطأ غير متوقع، حاول مرة أخرى.",
          "Are you sure you want to exit the application?": "هل أنت متأكد أنك تريد الخروج من التطبيق؟",
          "Are you sure you want to delete this photo?": "هل أنت متأكد أنك تريد حذف هذه الصورة؟",
          "You have not internet": "ليس لديك انترنت",

          // -- Validator Messages
          "Required field.": "حقل مطلوب.",
          "Email cannot empty.": "لا يمكن أن يكون البريد الإلكتروني فارغًا.",
          "Invalid email format.": "تنسيق البريد الإلكتروني غير صالح.",
          "Password does not match.": "كلمة المرور غير متطابقة.",
          "Password cannot empty.": "لا يمكن أن تكون كلمة المرور فارغة.",
          "The password must be greater than or equal": "يجب أن تكون كلمة المرور أكبر من أو تساوي",
          "characters.": "رموز.",
          "Too long password.": "كلمة المرور طويلة جدًا.",
          "The phone number must be numbers only.": "يجب أن يكون رقم الهاتف أرقامًا فقط.",
          "The phone number is too short.": "رقم الهاتف قصير جداً.",
          "The phone number is too long.": "رقم الهاتف طويل جداً.",
          "It must be numbers only.": "يجب أن تكون أرقامًا فقط.",
          "Too short.": "قصيرة جداً.",
          "Too long.": "طويل جداً.",
          
          // -- Firebase Auth Exception
          "Password is To weak...": "كلمة المرور ضعيفة...",
          "The account already exists for that email.": "الحساب موجود بالفعل لهذا البريد الإلكتروني",
          "No user found for that email.": "لم يتم العثور على مستخدم لهذا البريد الإلكتروني.",
          "Invalid password or email.": "كلمة المرور أو البريد الإلكتروني غير صالح.",
          "Oops! Some thing error! check your data and try again.": "عفواً! هناك خطأ ما! تحقق من بياناتك وحاول مرة أخرى.",


//
//================================== Start Common Widgets Messages ================================
          // check password widget
          "Please enter your password": "الرجاء إدخال كلمة المرور الخاصة بك",
          "Password": "كلمة المرور",
          "Check": "التحقق",
          "Failed to check password": "فشل في التحقق من كلمة المرور",
          
          // user tile widget
          "Account awaiting approval": "الحساب في انتظار الموافقة",
          "Account suspended": "الحساب معلق",
          "trainer account": "حساب مدرب",
          "admin account": "حساب مشرف",

//================================== Start Common Widgets Messages ================================
//


//
//================================== Start Welcome Messages ================================
          'Welcome': 'مرحباً',
          'We are happy to you join us': ' نحن سيعدون لإنضمامك إلينا',
          'Would you like to join as a': 'هل تريد الأنضمام كـ',
          'Trainer': 'مٌدرب',
          'Learner': 'مٌتدرب',
          
//================================== End Welcome Messages ================================
//


//
//================================== Start Auth Feature  Messages ================================
          // -- register screen
          "Let's create your account": "دعنا ننشئ حسابك",
          "Enter Your Email": "أدخل بريدك الإلكتروني",
          "Enter Your Name": "أدخل اسمك ",
          "Enter Your Password": "أدخل كلمة المرور ",
          "Please Confirm Your Password": "الرجاء تأكيد كلمة المرور",
          "Create Account": "إنشاء حساب ",
          "Already have an account?": "لديك حساب بالفعل؟",
          "Log in": "تسجيل الدخول",
          "Log In": "تسجيل الدخول",
          "I would like to offer training programs on the platform": "أرغب في تقديم برامج تدريبية على المنصة",
          "please creating a service provider account": "الرجاء إنشاء حساب مزود الخدمة",
          "You must confirm the creation of a service provider account.": "يجب عليك تأكيد إنشاء حساب مزود الخدمة.",

          // -- login screen
          "We are happy to you back": "نحن سعيدين بعودتك إلينا ",
          "Don't have an account?": "ليس لديك حساب ؟",
          "Sign up": "إنشاء حساب ",
          "Forget Password?": "نسيت كلمة السر؟",
          "User data not found. Please contact support.": "لم يتم العثور على بيانات المستخدم. يرجى الاتصال بالدعم.",
          
          // -- Forget Password Screen
          "Successful": "نجاح",
          "Open your email for a link to reset your password.": "افتح بريدك الإلكتروني للحصول على رابط لإعادة تعيين كلمة المرور الخاصة بك.",


          // -- Verify Email Screen
          "Please open your email to confirm your account so you can access your account and enjoy the benefits offered by the application.": "يرجى فتح بريدك الإلكتروني لتأكيد حسابك حتى تتمكن من الوصول إلى حسابك والاستمتاع بالمزايا التي يقدمها التطبيق.",
          "Check account status": "التحقق من حالة الحساب",
          "Resend": "إعادة الإرسال",
          "Back to login": "العودة إلى تسجيل الدخول",
          "A link to verify your account has been sent to your email.": "لقد تم إرسال رابط للتحقق من حسابك إلى بريدك الإلكتروني.",
          "Your account is not verified yet": "لم يتم التحقق من حسابك بعد",
          "Your account has been successfully verified.": "تم توثيق حسابك بنجاح",

          
          // -- created account screen
          "You're account created": "تم إنشاء حسابك ",

          // -- initial settings screen
          "Please select your favorite laungage": "الرجاء اختيار اللغة المفضلة لديك",
          "Allow us to send notifications to you": "اسمح لنا بإرسال الإشعارات إليك",
          "Let's create your profile": "دعنا ننشئ ملفك الشخصي",
          
          // -- profile screen
          "Name": "الاسم ",
          "Age": "العمر",
          "Enter Your Age": "أدخل عمرك ",
          "Gender": "الجنس",
          "Select Your Gender": "اختر جنسك",
          "Male": "ذكر",
          "Female": "أنثى",
          "Email": "البريد الالكتروني",
          "Save Edit": "حفظ التعديل",
          "The data has been modified successfully": "تم تعديل البيانات بنجاح",
          "We have sent a verification link to the new email to verify the email.\nOpen the link to change your account email": "لقد أرسلنا رابط التحقق إلى البريد الإلكتروني الجديد للتحقق من البريد الإلكتروني.\nافتح الرابط لتغيير بريدك الإلكتروني لحسابك",
          
//================================== End Auth Feature Messages ================================
//


//
//================================== Start Home Feature Messages ================================
          "There are no courses available": "لا يوجد دورات متاحة ",
          "Recently watched courses": "الدورات التي تمت مشاهدتها مؤخراً",
          "Activity details": "تفاصيل النشاط",
          "Rate of accomplishment": "معدل الإنجاز",
          "Duration of use": "مدة الاستخدام",
          
//================================== End Home Feater Messages ================================
//

          

//
//================================== Start Explore Feature Messages ================================
          // -- explore course  screen
          "Categories": "الفئات ",
          "Recently Added Courses": "الدورات المضافة مؤخراً",
          "Popular Courses": "الدورات الشائعة ",

          // -- preview course  screen
          "Course Preview": "معاينة الدورة ",
          "No description": "لا يوجد وصف",
          "Lessons": "االدروس",
          "Applicant": "تقديم طلب",
          "Go to watch the course": "اذهب لمشاهدة الدورة",
          "Your request has been rejected.": "لقد تم رفض طلبك.",
          "Your request is pending approval.": "طلبك في انتظار الموافقة.",
          "Cancel Request": "إلغاء الطلب",
          "The Trainer": "المدرب",
          "Registerations": "متدرب",
          "Show more": "عرض المزيد",
          "Show less": "عرض أقل",
          "The request has been sent successfully.": "تم ارسال الطلب بنجاح.",
          "The request was successfully cancelled.": "تم إلغاء الطلب بنجاح.",

          
      
//================================== End Explore Feature Messages ================================
//

          

//
//================================== Start Course Feature Messages ================================
          "Courses Registered": "الدورات المسجلة ",
          "You have not registered for any course yet.": "لم تقم بالتسجيل في أي دورة بعد.",
          "Joining date:": "تاريخ الانضمام:",
          "There are no lessons available": "لا توجد دروس متاحة",

          // -- Video Player Screen
          "Unexpected error while opening video, please contact support to solve the problem.": "خطأ غير متوقع أثناء فتح الفيديو، يرجى الاتصال بالدعم لحل المشكلة.",
          "Confirm Answer": "تأكيد الإجابة",


          // -- Quiz Screen
          "Question": "سؤال",
          "The video is not available or You have not internet": "الفيديو غير متاح أو ليس لديك اتصال بالإنترنت",
          "The quiz is not available or You have not internet": "الاختبار غير متاح أو ليس لديك اتصال بالإنترنت",
          "quiz": "اختبار",
          "lesson": "درس",
          "You must confirm your answer.": "يجب عليك تأكيد إجابتك.",
          
          // -- Quiz Result Screen
          "Quiz result": "نتيجة الاختبار",
          "QUIZ": "اختبار",
          "QUESTIONS": "اسئلة",
          "Your Quiz": "اختبارك",
          "Submit your quiz": "أرسل اختبارك",
          "DUE": "تاريخ الاستحقاق",
          "Correct answers": "الإجابات الصحيحة",
          "Wrong answers": "إجابات خاطئة",
          "Grade:": "الدرجة:",
          "Ok": "موافق",

          //  -- Lesson Question  Screen
          "Are you sure you want to stop the quiz?": "هل أنت متأكد أنك تريد إيقاف الاختبار؟",
          "Wrong answer": "اجابة خاطئة",
          "You must re-study the lesson and then try to answer the question correctly so that you can move on to the next lesson.": "يجب عليك إعادة الدرس ثم محاولة الإجابة على السؤال بشكل صحيح حتى تتمكن من الانتقال إلى الدرس التالي.",        
         
//================================== End Course Feature Messages ================================
//          


//
//================================== Start  Notification Feature Messages ================================
          "Notifications": "الاشعارات",
          "Missing notification?": " فقدت الاشعارات ؟ ",
          "Go to the historical Notification": "الانتقال الى الشعارات السابقة",
          "You send": "انت ارسلت",
          
          
//================================== End   Notification Feature Messages ================================
//
 
          

//
//================================== Start Setting Feature Messages ================================
        "Notification": "الاشعارات",
        "Language": "اللغة",
        "Theme Mode": "المظهر",
        "Help": " المساعدة",
        "Invite Friends": "دعوة الاصدقاء ",
        "Log out": "تسجيل الخروج",
        "Dark Mode": "الوضع الداكن",
        "Light Mode": "الوضع الفاتح",
//================================== End Sitteng Feature Messages ================================
//         


//
//================================== Start  Ta Home Feature Messages ================================
          "Trainers": "المدربين",
          "Learners": "المتدربين",
          "Applicants": "المتقدمون",
          "Courses": "الدورات",
          "The most requested courses": "الدورات الأكثر طلبا",
          "Most active course": "الدورة الأكثر نشاطا",
          "All your courses": "جميع دوراتك",
          "Your account is pending review and approval by the administration.": "حسابك في انتظار المراجعة والموافقة من قبل الإدارة.",
          "Your account has been temporarily suspended. Please contact support for further information.": "لقد تم تعليق حسابك مؤقتًا. يرجى الاتصال بالدعم للحصول على مزيد من المعلومات.",
          
          
//================================== End   Ta Home Feature Messages ================================
//


//
//================================== Start  Ta Trainers Learners Feature Messages ================================
          "Requests": "الطلبات",
          "Suspended": "المعلقة",
          "Accepted": "المقبولة",
          "Status": "الحالة",
          "waiting": "انتظار",
          "suspend": "معلق",
          "accepted": "مقبول",
          "Suspend": "تعليق",
          "Unsuspend": "إلغاء التعليق",
          "Accept": "قبول",

          
//================================== End  Ta Trainers Learners Feature Messages ================================
//


//
//================================== Start  Ta Courses Feature Messages ================================
          "There is a video is being uploaded to the database, if you exit the page the video might be unloaded.\nAre you sure you want to exit?": "هناك مقطع فيديو يتم تحميله إلى قاعدة البيانات، إذا خرجت من الصفحة، فقد يتم إلغاء تحميل الفيديو.\nهل أنت متأكد من أنك تريد الخروج؟", 
          "Course Details": "تفاصيل الدورة", 
          "Send": "ارسال", 
          "Unknown": "غير معروف", 
          "Waiting for the lesson video to be uploaded:": "في انتظار تحميل فيديو الدرس:", 
          "Please do not close this page and wait until the video upload is complete.": "من فضلك لا تغلق هذه الصفحة وانتظر حتى اكتمال تحميل الفيديو.", 
          "Important: If you close this page or upload another lesson, the current video upload will be cancelled.": "هام: إذا قمت بإغلاق هذه الصفحة أو تحميل درس آخر، فسيتم إلغاء تحميل الفيديو الحالي.", 
          "* Course video is not available": "* فيديو الدورة غير متاح", 
          "Upload now": "تحميل الآن", 
          "* Failed to upload lesson video": "* فشل تحميل فيديو الدرس", 
          "Are you sure you want to delete the course?": "هل أنت متأكد أنك تريد حذف الدورة؟", 
          "Deleted successfully": "تم الحذف بنجاح", 
          "Are you sure you want to delete the lesson?": "هل أنت متأكد أنك تريد حذف الدرس؟", 
          
          // -- send notification
          "Send a notification\n To all course participants": "إرسال إشعار\nإلى جميع المشاركين في الدورة", 
          "Notification Title": "عنوان الإشعار", 
          "Enter notification title": "أدخل عنوان الإشعار", 
          "Notification Body (optional)": "نص الإشعار (اختياري)", 
          "Enter notification body": "أدخل نص الإشعار", 
          
          // -- Add Course Screen
          "Add Course": "إضافة دورة", 
          "Category": "الفئة", 
          "Select course category": "اختر فئة الدورة", 
          "Enter course name": "أدخل اسم الدورة", 
          "Description (optional)": "الوصف (اختياري)", 
          "Enter course description": "أدخل وصف الدورة", 
          "Icon (optional)": "الأيقونة (اختياري)", 
          "Add course icon": "إضافة أيقونة الدورة", 
          "We could not load the course icon, please try again after uploading the course data": "لم نتمكن من تحميل أيقونة الدورة، يرجى المحاولة مرة أخرى بعد تحميل بيانات الدورة", 
          "Course data has been uploaded successfully.": "تم تحميل بيانات الدورة بنجاح.", 
          
          // -- Add Lesson Screen
          "Type": "النوع", 
          "Please choose the type of lesson": "الرجاء اختيار نوع الدرس", 
          "Lesson number": "رقم الدرس", 
          "Important for lessons presentation sequence.": "مهم لتسلسل عرض الدروس.", 
          "Enter lesson number": "أدخل رقم الدرس", 
          "Title": "العنوان", 
          "Enter lesson title": "أدخل عنوان الدرس", 
          "Enter lesson description": "أدخل وصف الدرس", 
          "Lesson Question": "سؤال الدرس", 
          "Enter lesson question": "أدخل سؤال الدرس", 
          "Question Answers": "اجابات السؤال", 
          "Enter the possible answers and choose the correct answer.": "أدخل الإجابات الممكنة ثم اختر الإجابة الصحيحة.", 
          "Enter Answer": "أدخل الإجابة", 
          "Add Answer": "أضافة إجابة", 
          "Video": "فيديو", 
          "Click to delete this question": "انقر هنا لحذف هذا السؤال", 
          "Add Question": "اضافة سؤال", 
          "Add lesson video": "إضافة فيديو الدرس", 
          "There is another video being uploaded.": "هناك فيديو آخر يتم تحميله.", 
          "Quiz data has been uploaded successfully.": "تم تحميل بيانات الاختبار بنجاح.", 
          "Lesson data has been uploaded successfully.": "تم تحميل بيانات الدرس بنجاح.", 
          "Video uploaded successfully": "تم تحميل الفيديو بنجاح", 

          
//================================== End  Ta Courses Feature Messages ================================
//




        },

        ///========================English=====================///
      };
}
