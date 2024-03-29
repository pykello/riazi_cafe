# Title
سه سوال از تورنمنت هاروارد-ام‌آی‌تی ۲۰۰۸
# Timestamp
2023-11-13 22:00
# Source
hmmt
# ID
هاروارد-ام‌آی‌تی ۱
# Tags
combinatorics,algebra,number-theory
# Difficulty
0
# Statement
1. کوچکتر‌ین عدد صحیح مثبت n که دو رقم سمت راست آن با دو رقم سمت راست 107n برابر باشه چنده؟
2. مجموع اعضای چند تا از زیرمجموعه‌های {2,1,...,63} برابر با ۲۰۰۸ ه؟
3. در شکل زیر چند مستطیل (با مساحت ناصفر) وجود دارد که اضلاع آن کاملا روی خطوط قرار بگیرد؟

    ![](/images/problems/hmmt01.png)

لینک توویتر:
* https://twitter.com/Riazi_Cafe/status/1714160298733814199
* https://twitter.com/Riazi_Cafe/status/1715620091164057994


# Solution

**سوال ۱**. برای اینکه دو رقم راست دو عدد یکی باشند، باید باقیمانده هر دو بر ۱۰۰ برابر باشد. پس:

$$
\begin{aligned}
107n \equiv n\ (\textrm{mod}\ 100) &\implies \\\\
7n \equiv n\ (\textrm{mod}\ 100) &\implies \\\\
6n \equiv 0\ (\textrm{mod}\ 100) &
\end{aligned}
$$

و کوچکترین عدد مثبتی که باقیمانده‌ی ۶ برابر آن بر ۱۰۰ صفر باشد، ۵۰ است.

**سوال ۲**. مجموع ۱ تا ۶۳ برابر است با $63*64/2 = 2016$. یه زیرمجموعه با مجموع ۲۰۰۸، شامل همه‌ی اعداد به غیر از تعدادی که مجموعشون ۸ ه است. پس کافیه تعداد زیرمجموعه‌هایی که مجموعشون ۸ میشه رو بشمریم.

* یک عضوی: $\\{8\\}$
* دو عضوی: $\\{1,7\\}$ ، $\\{2,6\\}$ ، $\\{3,5\\}$
* سه عضوی: $\\{1,2,5\\}$ ، $\\{1,3,4\\}$

پس پاسخ برابر است با ۶.

**سوال ۳**. با انتخاب ۲ ضلع عمودی و ۲ ضلع افقی می‌توان یک مستطیل ساخت. پس تعداد کل مستطیل‌ها، صرف‌نظر از اینکه ضلعی از نقطه‌ی مرکزی می‌گذرد یا نه، برابر است با
${7 \choose 2}{7 \choose 2} = 21 . 21 = 441$.

اگر یکی از ضلع‌های افقی مستطیل از نقطه‌ی مرکزی بگذرد، برای دیگر ضلع افقی ۶ انتخاب داریم، و برای ۲ ضلع عمودی به طوری که نقطه‌ی مرکز شامل روی ضلع مستطیل بیفتد، ۱۵ انتخاب.
پس $15 * 6=90$ حالت داریم که یکی از ضلع‌های افقی از نقطه‌ی مرکز رد شود.

به طور مشابه ۹۰ حالت داریم که یکی از ضلع‌های عمودی از نقطه‌ی مرکز رد شود.

برای اینکه هم یک ضلع افقی و هم یک ضلع عمودی همزمان از نقطه‌ی مرکزی رد شوند، یکی از گوشه‌های مستطیل باید در نقطه‌ی مرکز باشد. پس تعداد این حالت‌ها هم برابر است با تعداد حالت‌هایی که
گوشه‌ی روبرو رو بتوانیم انتخاب کنیم، یعنی ۳۶ حالت.

پس پاسخ نهایی برابر است با $441 - 2 * 90 + 36 = 297$.
