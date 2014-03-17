theory Library_Misc
imports Distribution_Functions

begin

(** General miscellaneous. **)

(* This should be easy. *)
lemma ereal_le_epsilon_iff2: "(\<forall>\<epsilon>>0. x \<le> y + ereal \<epsilon>) = (x \<le> y)" using ereal_le_epsilon2
by (metis add_commute add_right_mono dual_order.trans ereal_less(2) less_eq_ereal_def
    monoid_add_class.add.left_neutral)

lemma inj_on_infinite: "infinite A \<Longrightarrow> inj_on f A \<Longrightarrow> infinite (range f)"
  by (metis finite_imageD image_mono rev_finite_subset top_greatest)

lemma real_rats_infinite: "infinite \<rat>"
  apply (subst Rats_def)
  apply (rule inj_on_infinite)
  apply (rule infinite_UNIV_char_0)
  unfolding inj_on_def by auto

lemma indicator_abs_eq[simp]:
  "\<bar>indicator A x\<bar> = ((indicator A x)::'a::linordered_idom)"
  by simp

lemma indicator_disj_union:
  assumes "A \<inter> B = {}"
  shows "indicator (A \<union> B) x = indicator A x + (indicator B x :: 'a::ring_1)"
  by (auto simp add: indicator_union_arith indicator_inter_arith[symmetric] assms)

lemma indicator_disj_un_fun:
  assumes "A \<inter> B = {}"
  shows "indicator (A \<union> B) = (\<lambda>x. indicator A x +
  (indicator B x :: 'a::ring_1))"
  by (auto simp add: indicator_union_arith indicator_inter_arith[symmetric] assms)

lemma mult_indicator_subset:
  assumes sub: "A \<subseteq> B"
  shows "\<And>x. indicator A x * indicator B x = ((indicator A x)::real)"
  apply (case_tac "x \<in> A")
  apply (subgoal_tac "x \<in> B")
  apply auto
  by (metis in_mono sub)

lemma setseq_inc:
  "(\<And>i::nat. A i \<subseteq> A (i+1)) \<Longrightarrow> i \<le> j \<Longrightarrow> A i \<subseteq> A j"
  by (rule lift_Suc_mono_le) simp_all

lemma setseq_dec:
  assumes dec: "\<And>i::nat. A (i+1) \<subseteq> A i" "i \<le> j"
  shows "A j \<subseteq> A i"
  using assms(2,1)
  by (induct rule: dec_induct) auto

lemma indicator_cont_up:
  assumes inc: "\<And>i::nat. A i \<subseteq> A (i+1)"
  shows "(\<lambda>i::nat. (indicator (A i) x)::real) ----> indicator (\<Union>i. A i) x"
  using LIMSEQ_indicator_UN
proof -
  have "\<And>i j. i \<le> j \<Longrightarrow> A i \<subseteq> A j"
    using inc setseq_inc[of A] by auto  
  then have "\<And>k. (\<Union> i<Suc k. A i) = A k"
    by (force simp: less_Suc_eq_le)
  with LIMSEQ_indicator_UN[of A x, THEN LIMSEQ_Suc]
  show ?thesis
    by simp
qed

(** Also prove indicator_cont_down. **)
              
lemma tendsto_const_add:
  fixes a b :: "'a::real_normed_vector"
  assumes "((\<lambda>x. a + f x) ---> a + b) F"
  shows "(f ---> b) F"
proof -
  have "((\<lambda>x. (a + f x) - a) ---> (a + b) - a) F"
    by (intro tendsto_diff tendsto_const assms)
  then show ?thesis
    by simp
qed

lemma tendsto_const_mult:
  fixes a b :: real
  assumes nonzero: "a \<noteq> 0"
  and lim: "((\<lambda>x. a * f x) ---> a * b) F"
  shows "(f ---> b) F"
proof -
  have "((\<lambda>x. (a * f x) / a) ---> (a * b) / a) F"
    by (intro tendsto_divide tendsto_const assms)
  with nonzero show ?thesis
    by simp
qed

lemma real_of_ereal_neq_0:
fixes x::ereal
assumes "real x \<noteq> 0"
shows "x = ereal (real x)"
by (metis assms ereal_eq_0(1) ereal_real)

(* Why aren't these in Set_Interval.thy?? *)
lemma setprod_atMost_Suc[simp]: "(\<Prod>i \<le> Suc n. f i) = (\<Prod>i \<le> n. f i) * f(Suc n)"
by (simp add:atMost_Suc mult_ac)

lemma setprod_lessThan_Suc[simp]: "(\<Prod>i < Suc n. f i) = (\<Prod>i < n. f i) * f n"
by (simp add:lessThan_Suc mult_ac)

lemma norm_setprod: "norm (\<Prod>i \<in> A. f i) = 
  (\<Prod> i \<in> A. norm ((f i) :: 'a :: {real_normed_div_algebra,comm_monoid_mult}))"
apply (case_tac "finite A", auto)
apply (erule finite_induct, auto simp add: norm_mult)
done

(** Miscellany from Helly. **)

(* Why were these not in the library? *)
lemma measure_cong_AE: "AE x in M. f x = g x \<Longrightarrow> (f \<in> measurable M N) = (g \<in> measurable M N)"
  sorry
  
(* Perhaps generalize to arbitrary T1 spaces *)
lemma lborel_countable:
fixes A M
assumes "A \<subseteq> space M" "countable A"
shows "A \<in> sets M"
sorry

(* This should have been in the library, like convergent_limsup_cl. *)
lemma convergent_liminf_cl:
  fixes X :: "nat \<Rightarrow> 'a::{complete_linorder,linorder_topology}"
  shows "convergent X \<Longrightarrow> liminf X = lim X"
  by (auto simp: convergent_def limI lim_imp_Liminf)

primrec halfseq :: "real \<Rightarrow> real \<Rightarrow> nat \<Rightarrow> real" where
  "halfseq l a0 0 = a0"
| "halfseq l a0 (Suc n) = (halfseq l a0 n + l) / 2"

lemma halfseq_converges: "halfseq l a0 ----> l"
proof -
  let ?a = "halfseq l a0"
  {
    fix n
    have "dist (?a n) l = dist a0 l / 2^n"
      by (induct n, auto simp add: dist_real_def field_simps)
  } note dist_a = this
  show ?thesis
  proof (rule metric_LIMSEQ_I)
    fix r :: real
    assume [simp]: "r > 0"
    from reals_Archimedean2 [of "dist a0 l / r"] guess n .. 
    with `r > 0` have 2: "dist a0 l < r * n" by (simp add: field_simps)
    have "(dist a0 l) / 2^n < r"
      apply (auto simp add: field_simps)
      apply (rule order_less_trans, rule 2)
      by (rule mult_strict_left_mono, simp_all)
    hence "\<forall>m\<ge>n. dist (halfseq l a0 m) l < r"
      apply (auto simp add: dist_a)
      apply (rule order_le_less_trans)
      prefer 2 apply assumption
      by (auto simp add: field_simps intro!: mult_left_mono)
    thus "\<exists>n. \<forall>m\<ge>n. dist (halfseq l a0 m) l < r" ..
  qed
qed

lemma real_Inf_greatest': 
  fixes A and x :: real 
  assumes "A \<noteq> {}" "bdd_below A" and 1: "x > Inf A" 
  shows "\<exists>y \<in> A. y \<le> x"
apply (rule contrapos_pp [OF 1], simp add: not_less not_le)
using assms cInf_greatest le_less by metis

lemma bdd_below_closure:
  fixes A :: "real set"
  assumes "bdd_below A"
  shows "bdd_below (closure A)"
proof -
  from assms obtain m where "\<And>x. x \<in> A \<Longrightarrow> m \<le> x" unfolding bdd_below_def by auto
  hence "A \<subseteq> {m..}" by auto
  hence "closure A \<subseteq> {m..}" using closed_real_atLeast closure_minimal by auto
  thus ?thesis unfolding bdd_below_def by auto
qed

lemma real_closed_subset_contains_Inf:
  fixes A C :: "real set"
  assumes cl: "closed C" and A: "A \<subseteq> C"
  and nonempty: "A \<noteq> {}" and bdd_below: "bdd_below A"
  shows "Inf A \<in> C"
proof -
  have "closure A \<subseteq> C" using closure_minimal assms by auto
  thus ?thesis
    apply (elim subsetD)
    apply (rule closure_contains_Inf)
    using assms by auto
qed

(* Should this definition be eliminated? **)
definition rcont_inc :: "(real \<Rightarrow> real) \<Rightarrow> bool"
  where "rcont_inc f \<equiv> (\<forall>x. continuous (at_right x) f) \<and> mono f"

lemma real_atLeastAtMost_subset_contains_Inf:
  fixes A :: "real set" and a b :: real assumes "A \<noteq> {}" and "bdd_below A"
  and "a \<le> b" and "A \<subseteq> {a..b}"
  shows "Inf A \<in> {a..b}"
by (rule real_closed_subset_contains_Inf, rule closed_real_atLeastAtMost) (simp_all add: assms)

lemma rat_unbounded: "\<exists> q \<in> \<rat>. (x :: real) \<le> q"
  apply (rule_tac x = "of_nat (natceiling x)" in bexI, auto)
by (metis real_natceiling_ge real_of_nat_def)

lemma f_inv_f_surj_on: "f ` A = B \<Longrightarrow> x \<in> B \<Longrightarrow> f (inv f x) = x"
  apply auto
  unfolding inv_def by (rule someI_ex, auto)

lemma dist_epsilon: "\<forall>\<epsilon>>0. dist x y < \<epsilon> \<Longrightarrow> x = y" using dist_pos_lt less_irrefl by auto

lemma ereal_dist_epsilon:
  assumes "\<forall>(\<epsilon>::real)>0. \<bar>x - ereal r\<bar> < \<epsilon>"
  shows "x = ereal r"
proof (rule ereal_cases[of x])
  fix t assume x: "x = ereal t"
  { fix \<epsilon>::real assume \<epsilon>: "\<epsilon> > 0"
    hence "\<bar>ereal t - ereal r\<bar> < \<epsilon>" using assms x \<epsilon> by auto
    hence "dist t r < \<epsilon>" unfolding dist_real_def by auto
  }
  hence "ereal t = ereal r" using dist_epsilon by auto
  thus ?thesis using x by simp
next
  assume "x = \<infinity>"
  hence "\<bar>x - ereal r\<bar> = \<infinity>" by auto
  hence "\<not> \<bar>x - ereal r\<bar> < ereal 1" by auto
  hence False using assms by auto
  thus ?thesis ..
next (* Duplication; how to avoid? *)
  assume "x = -\<infinity>"
  hence "\<bar>x - ereal r\<bar> = \<infinity>" by auto
  hence "\<not> \<bar>x - ereal r\<bar> < ereal 1" by auto
  hence False using assms by auto
  thus ?thesis ..
qed

lemma lim_close_limsup_liminf:
  fixes a :: "nat \<Rightarrow> ereal" and L :: real
  assumes "\<forall>(e::real)>0. \<bar>limsup a - L\<bar> < e \<and> \<bar>L - liminf a\<bar> < e"
  shows "convergent a" and "lim a = L"
proof -
  have lsup: "limsup a = L" using ereal_dist_epsilon assms by auto
  also have "L = liminf a"
  proof -
    have "\<And>n::nat. n > 0 \<Longrightarrow> \<bar>L - liminf a\<bar> < inverse n" using assms
      by (metis inverse_positive_iff_positive real_of_nat_gt_zero_cancel_iff)
    hence 1: "\<bar>L - liminf a\<bar> = 0"
      using ereal_dist_epsilon by (metis abs_ereal_zero assms ereal_minus(7) zero_ereal_def)
    show ?thesis
    proof -
      have "\<bar>liminf a\<bar> < \<infinity>" using 1
        by (metis PInfty_neq_ereal(1) abs_eq_infinity_cases abs_ereal_uminus add_commute ereal_less_PInfty ereal_minus(3)
            minus_ereal_def plus_ereal.simps(2) zero_ereal_def)  
      then obtain linf where linf: "ereal linf = liminf a" by auto
      hence "\<bar>L - linf\<bar> = 0" using 1 by (metis abs_ereal.simps(1) ereal_eq_0(2) ereal_minus(1))
      hence "linf = L" by auto
      thus ?thesis using linf by auto
    qed
  qed
  finally have "limsup a = liminf a" by simp
  thus "convergent a" using convergent_ereal by auto
  hence "limsup a = lim a" using convergent_limsup_cl by auto
  thus "lim a = L" using lsup by simp
qed

lemma convergent_real_imp_convergent_ereal:
  assumes "convergent a"
  shows "convergent (\<lambda>n. ereal (a n))" and "lim (\<lambda>n. ereal (a n)) = ereal (lim a)"
proof -
  from assms obtain L where L: "a ----> L" unfolding convergent_def ..
  hence lim: "(\<lambda>n. ereal (a n)) ----> ereal L" using lim_ereal by auto
  thus "convergent (\<lambda>n. ereal (a n))" unfolding convergent_def ..
  thus "lim (\<lambda>n. ereal (a n)) = ereal (lim a)" using lim L limI by metis
qed

lemma ereal_not_infty:
  fixes x :: ereal and B :: real
  assumes "x \<le> ereal B"
  shows "x \<noteq> \<infinity>"
by (metis PInfty_neq_ereal(1) assms ereal_infty_less_eq(1))

lemma abs_bounds: "x \<le> y \<Longrightarrow> -x \<le> y \<Longrightarrow> abs (x :: ereal) \<le> y"
by (metis abs_ereal_ge0 abs_ereal_uminus ereal_0_le_uminus_iff linear)

(** For Weak_Convergence **)

lemma bdd_rcont_inc_pseudoinverse:
  fixes F :: "real \<Rightarrow> real"
  fixes M a b :: real
  assumes "a < b" and rcont_inc: "rcont_inc F"
    and F_at_bot: "(F ---> a) at_bot" and F_at_top: "(F ---> b) at_top"
  shows "\<forall>\<omega>\<in>{a<..<b}. \<forall>x. (\<omega> \<le> F x) = (Inf {x. \<omega> \<le> F x} \<le> x)"
proof safe
  fix \<omega> x :: real assume interval: "\<omega> \<in> {a<..<b}"
  def Y \<equiv> "\<lambda>\<omega>. Inf {x. \<omega> \<le> F x}"
  {
    assume "\<omega> \<le> F x"
    hence "x \<in> {x. \<omega> \<le> F x}" using interval by auto
    thus "Y \<omega> \<le> x" unfolding Y_def
      apply (rule cInf_lower)
      proof (unfold bdd_below_def Ball_def, auto)
        from F_at_bot have "\<exists>y. F y < \<omega>" unfolding filterlim_def le_filter_def
          apply (subst (asm) eventually_filtermap)
          apply (subst (asm) eventually_at_bot_linorder)
          apply (drule_tac x = "\<lambda>z. z < \<omega>" in allE[where R = "\<exists>y. F y < \<omega>"], auto)
          using interval by (metis F_at_bot eventually_at_bot_linorder greaterThanLessThan_iff order_refl order_tendsto_iff) 
      then guess y .. note y = this
      hence "\<forall>x. \<omega> \<le> F x \<longrightarrow> y \<le> x" using rcont_inc unfolding rcont_inc_def mono_def
        by (metis dual_order.irrefl le_cases le_less_trans)
      thus "\<exists>m. \<forall>x. \<omega> \<le> F x \<longrightarrow> m \<le> x" by auto
    qed
  }
  {
    assume "Y \<omega> \<le> x"
    hence x_less: "\<And>y. x < y \<Longrightarrow> \<omega> \<le> F y"
    proof (unfold Y_def)
      fix y assume x: "Inf {x. \<omega> \<le> F x} \<le> x" and y: "x < y"
      show "\<omega> \<le> F y"
      proof (rule ccontr)
        assume "\<not> \<omega> \<le> F y"
        hence "F y < \<omega>" by simp
        hence le: "\<And>z. z \<le> y \<Longrightarrow> F z < \<omega>" using rcont_inc le_less_trans unfolding rcont_inc_def mono_def by metis
        have "y \<le> Inf {x. \<omega> \<le> F x}"
          apply (rule cInf_greatest)
          prefer 2 using le
          apply (metis (lifting) Int_Collect inf_sup_aci(1) le_cases max.semilattice_strict_iff_order not_less_iff_gr_or_eq)
          apply (subgoal_tac "(\<lambda>k::nat. F (real k)) ----> b")
          apply (drule LIMSEQ_D[of _ _ "b - \<omega>"])
          using interval(1) apply (metis diff_less_iff(1) greaterThanLessThan_iff)
          prefer 2
          using F_at_top rcont_inc tendsto_at_topI_sequentially assms unfolding rcont_inc_def mono_def
            apply (metis filterlim_compose filterlim_real_sequentially)      
          proof -
            assume 1: "\<exists>no::nat. \<forall>k\<ge>no. norm (F (real k) - b) < b - \<omega>"
            then guess no .. note no = this
            hence "norm (F (real no) - b) < b - \<omega>" by simp
            hence "\<omega> \<le> F (real no)" by auto
            thus "{x. \<omega> \<le> F x} \<noteq> {}" by auto
          qed
        hence "y \<le> x" using x by simp
        thus False using y by simp
      qed
    qed
    show "\<omega> \<le> F x"
    proof (rule field_le_epsilon)
      fix e::real assume e: "0 < e"
      hence "\<exists>\<delta>>0. F (x + \<delta>) - F x < e"
        using continuous_at_right_real_increasing rcont_inc unfolding rcont_inc_def mono_def by auto
      then guess \<delta> .. note \<delta> = this
      have \<delta>: "\<delta> > 0" "F (x + \<delta>) - F x < e" using \<delta> by simp_all
      hence "\<omega> \<le> F (x + \<delta>)" using x_less \<delta> by auto
      thus "\<omega> \<le> F x + e" using \<delta>(2) by simp
    qed
  }
qed

lemma interval_cases:
  fixes S :: "'a :: conditionally_complete_linorder set"
  assumes ivl: "\<And>a b x. a \<in> S \<Longrightarrow> b \<in> S \<Longrightarrow> a \<le> x \<Longrightarrow> x \<le> b \<Longrightarrow> x \<in> S"
  shows "\<exists>a b. S = {} \<or> S = UNIV \<or> S = {..<b} \<or> S = {..b} \<or> S = {a<..} \<or> S = {a..} \<or>
    S = {a<..<b} \<or> S = {a<..b} \<or> S = {a..<b} \<or> S = {a..b}"
proof -
  def lower \<equiv> "{x. \<exists>s\<in>S. s \<le> x}" and upper \<equiv> "{x. \<exists>s\<in>S. x \<le> s}"
  with ivl have "S = lower \<inter> upper"
    by auto
  moreover 
  have "\<exists>a. upper = UNIV \<or> upper = {} \<or> upper = {.. a} \<or> upper = {..< a}"
  proof cases
    assume *: "bdd_above S \<and> S \<noteq> {}"
    from * have "upper \<subseteq> {.. Sup S}"
      by (auto simp: upper_def intro: cSup_upper2)
    moreover from * have "{..< Sup S} \<subseteq> upper"
      by (force simp add: less_cSup_iff upper_def subset_eq Ball_def)
    ultimately have "upper = {.. Sup S} \<or> upper = {..< Sup S}"
      unfolding ivl_disj_un(2)[symmetric] by auto
    then show ?thesis by auto
  next
    assume "\<not> (bdd_above S \<and> S \<noteq> {})"
    then have "upper = UNIV \<or> upper = {}"
      by (auto simp: upper_def bdd_above_def not_le dest: less_imp_le)
    then show ?thesis
      by auto
  qed
  moreover
  have "\<exists>b. lower = UNIV \<or> lower = {} \<or> lower = {b ..} \<or> lower = {b <..}"
  proof cases
    assume *: "bdd_below S \<and> S \<noteq> {}"
    from * have "lower \<subseteq> {Inf S ..}"
      by (auto simp: lower_def intro: cInf_lower2)
    moreover from * have "{Inf S <..} \<subseteq> lower"
      by (force simp add: cInf_less_iff lower_def subset_eq Ball_def)
    ultimately have "lower = {Inf S ..} \<or> lower = {Inf S <..}"
      unfolding ivl_disj_un(1)[symmetric] by auto
    then show ?thesis by auto
  next
    assume "\<not> (bdd_below S \<and> S \<noteq> {})"
    then have "lower = UNIV \<or> lower = {}"
      by (auto simp: lower_def bdd_below_def not_le dest: less_imp_le)
    then show ?thesis
      by auto
  qed
  ultimately show ?thesis
    unfolding greaterThanAtMost_def greaterThanLessThan_def atLeastAtMost_def atLeastLessThan_def
    by (elim exE disjE) auto
qed

lemma is_real_interval:
  assumes S: "is_interval S"
  shows "\<exists>a b::real. S = {} \<or> S = UNIV \<or> S = {..<b} \<or> S = {..b} \<or> S = {a<..} \<or> S = {a..} \<or>
    S = {a<..<b} \<or> S = {a<..b} \<or> S = {a..<b} \<or> S = {a..b}"
  using S unfolding is_interval_1 by (blast intro: interval_cases)

(*

(* Should have theorem that connected sets are Borel measurable. *)

(* JOHANNES: Actually connected => Borel only for reals / ereals. *)

lemma Sup_real_set_eq_PInfty:
  fixes S :: "real set"
  assumes "Sup (ereal ` S) = \<infinity>"
  shows "\<forall>x. \<exists>y\<in>S. x < y"
proof
  fix x :: real
  show "\<exists>y\<in>S. x < y"
  proof (rule ccontr, auto simp add: linorder_not_less)
    assume "\<forall>y\<in>S. y \<le> x"
    thus False using assms Sup_least[of "ereal ` S" x]
      by (metis ereal_less_eq(3) ereal_not_infty image_iff) 
  qed
qed

(* Should be able to quickly deduce from above using unimus_Sup. *)
lemma Inf_real_set_eq_MInfty:
  fixes S :: "real set"
  assumes "Inf (ereal ` S) = -\<infinity>"
  shows "\<forall>x. \<exists>y\<in>S. y < x"
proof
  fix x :: real
  show "\<exists>y\<in>S. y < x"
  proof (rule ccontr, auto simp add: linorder_not_less)
    assume "\<forall>y\<in>S. x \<le> y"
    thus False using assms Inf_greatest[of "ereal ` S" x]
      by (metis MInfty_neq_ereal(1) dual_order.antisym ereal_less_eq(2) ereal_less_eq(3) image_iff)
  qed
qed 

lemma is_real_interval:
  assumes "is_interval S"
  shows "\<exists>a b::real. S = {} \<or> S = UNIV \<or> S = {..<b} \<or> S = {..b} \<or> S = {a<..} \<or> S = {a..} \<or>
    S = {a<..<b} \<or> S = {a<..b} \<or> S = {a..<b} \<or> S = {a..b}"
proof -
  def \<alpha> \<equiv> "Inf (ereal ` S)"
  def \<beta> \<equiv> "Sup (ereal ` S)"
  have asm: "\<forall>a\<in>S. \<forall>b\<in>S. \<forall>x. a \<le> x \<and> x \<le> b \<or> b \<le> x \<and> x \<le> a \<longrightarrow> x \<in> S"
    unfolding is_interval_def Basis_real_def inner_real_def by (metis assms is_interval_1) 
  show ?thesis
  proof (rule ereal_cases[of \<alpha>], rule ereal_cases[of \<beta>])
    fix a b assume a: "\<alpha> = ereal a" and b: "\<beta> = ereal b"
    show ?thesis
    proof (cases "a \<in> S", cases "b \<in> S")
      assume a': "a \<in> S" and b': "b \<in> S"
      have "S = {a..b}"
        apply auto
        using a Inf_lower unfolding \<alpha>_def apply (metis ereal_less_eq(3) image_eqI)
        using b Sup_upper unfolding \<beta>_def apply (metis ereal_less_eq(3) image_eqI)
        using asm a' b' by blast
      thus ?thesis by auto
    next
      assume a': "a \<in> S" and b': "b \<notin> S"
      have "S = {a..<b}"
        apply auto
        using a Inf_lower unfolding \<alpha>_def apply (metis ereal_less_eq(3) image_eqI)
        using asm b Sup_upper unfolding \<beta>_def apply (metis b' image_iff less_ereal.simps(1) not_le) 
        proof -
          fix x::real assume ax: "a \<le> x" and xb: "x < b"
          show "x \<in> S"
          proof (rule ccontr)
            assume xS: "x \<notin> S"
            have "\<exists>y. x < y \<and> y < b" using xb dense by auto
            then guess y .. note y = this
            hence "\<And>z. z \<in> S \<Longrightarrow> z \<le> y" using asm a' ax xS by (metis le_cases le_less_trans less_imp_le)
            hence "\<beta> \<le> y" unfolding \<beta>_def using Sup_least by (metis (hide_lams, mono_tags) ereal_less_eq(3) image_iff)
            have "b \<le> y" unfolding \<beta>_def by (metis `\<beta> \<le> ereal y` b ereal_less_eq(3))
            thus False using y by auto
          qed
        qed
        thus ?thesis by auto
      next
        assume a': "a \<notin> S"
        show ?thesis
        proof (cases "b \<in> S")
          assume b': "b \<in> S"
          have "S = {a<..b}"
            apply auto
            prefer 2
            using b Sup_upper unfolding \<beta>_def apply (metis ereal_less_eq(3) image_eqI)
            using asm a Inf_lower unfolding \<alpha>_def apply (metis a' image_iff less_ereal.simps(1) not_le)
            proof -
              fix x::real assume ax: "a < x" and xb: "x \<le> b"
              show "x \<in> S"
              proof (rule ccontr)
                assume xS: "x \<notin> S"
                have "\<exists>y. a < y \<and> y < x" using ax dense by auto
                then guess y .. note y = this
                hence "\<And>z. z \<in> S \<Longrightarrow> y \<le> z" using asm b' xb xS by (metis le_cases le_less_trans less_imp_le)
                hence "y \<le> \<alpha>" unfolding \<alpha>_def using Inf_greatest by (metis (hide_lams, mono_tags) ereal_less_eq(3) image_iff)
                have "y \<le> a" unfolding \<alpha>_def by (metis `ereal y \<le> \<alpha>` a ereal_less_eq(3))
                thus False using y by auto
              qed
            qed
            thus ?thesis by auto
          next
            assume b': "b \<notin> S"
            have "S = {a<..<b}"
              apply auto
              using asm a Inf_lower unfolding \<alpha>_def apply (metis a' image_iff less_ereal.simps(1) not_le)
              using asm b Sup_upper unfolding \<beta>_def apply (metis b' image_iff less_ereal.simps(1) not_le)
              proof -
                fix x::real assume ax: "a < x" and xb: "x < b"
                show "x \<in> S"
                proof (rule ccontr)
                  assume xS: "x \<notin> S"
                  have "\<exists>y. a < y \<and> y < x" using ax dense by auto
                  then guess y .. note y = this
                  have "\<exists>w. x < w \<and> w < b" using xb dense by auto
                  then guess w .. note w = this
                  from Inf_ereal_close[of "ereal ` S" "(y - a)/2"] a
                  have "\<exists>x'\<in>ereal ` S. x' < \<alpha> + ereal ((y - a) / 2)"
                    by (smt PInfty_neq_ereal(1) \<alpha>_def abs_ereal.simps(1) divide_pos_pos ereal_less(2) w y)
                  then guess x' .. note x' = this
                  hence "\<exists>r'. x' = ereal r'" by auto
                  then guess r' .. note r' = this
                  hence r'S: "r' \<in> S" using x' unfolding \<alpha>_def by auto
                  have ar': "a < r'" using r' x' a unfolding \<alpha>_def
                    by (metis Inf_lower a' leD less_ereal.simps(1) linorder_cases r'S)
                  have nonempty: "S \<noteq> {}" using a empty_iff r'S unfolding \<alpha>_def by auto
                  with Sup_ereal_close[of "(b - w)/2" "ereal ` S"] b
                  have "\<exists>z'\<in>ereal ` S. \<beta> - ereal ((b - w)/2) < z'"
                    by (metis PInfty_neq_ereal(1) \<beta>_def abs_ereal.simps(1) diff_less_iff(1) ereal_between(1)
                        ereal_less(2) half_gt_zero less_Sup_iff w) 
                  then guess z' .. note z' = this
                  hence "\<exists>s'. z' = ereal s'" by auto
                  then guess s' .. note s' = this
                  hence s'S: "s' \<in> S" using z' unfolding \<beta>_def by auto
                  have s'b: "s' < b" using s' z' b unfolding \<beta>_def
                    by (metis b' less_Sup_iff less_ereal.simps(1) less_irrefl linorder_cases s'S)
                  have "r' < a + (y - a)/2" using r' x' a by auto
                  hence r'x: "r' < x" using y by (smt real_sum_of_halves)
                  have "b - (b - w)/2 < s'" using s' z' b by auto
                  hence "x < s'" using w by (smt real_sum_of_halves)
                  with r'x have "x \<in> S" using asm r'S s'S by (metis less_eq_real_def) 
                  thus False using xS by safe
                qed
              qed
              thus ?thesis by auto
            qed
          qed
        next
          fix a::real assume a: "\<alpha> = ereal a"
          { assume \<beta>: "\<beta> = \<infinity>"
            show ?thesis
            proof (cases "a \<in> S")
              assume "a \<in> S"
              hence "S = {a..}"
                apply auto
                using a Inf_lower unfolding \<alpha>_def apply (metis ereal_less_eq(3) imageI)
                using asm \<beta> Sup_real_set_eq_PInfty by (metis \<beta>_def less_imp_le)
              thus ?thesis by auto
            next
              assume "a \<notin> S"
              hence "S = {a<..}"
                apply auto
                using asm a Inf_lower unfolding \<alpha>_def apply (metis image_eqI less_ereal.simps(1) not_le)
                proof -
                  fix x :: real assume x: "a < x"
                  have "\<exists>y. a < y \<and> y < x" using x dense by auto
                  then guess y .. note y = this
                  from Sup_real_set_eq_PInfty \<beta> have "\<exists>z\<in>S. x < z" unfolding \<beta>_def by auto
                  then guess z .. note z = this
                  show "x \<in> S"
                  proof (rule ccontr)
                    assume xS: "x \<notin> S"
                    hence "\<And>z. z \<in> S \<Longrightarrow> y \<le> z" using asm x y z xS by (metis dual_order.strict_trans1 le_cases le_less)
                    hence "y \<le> \<alpha>" unfolding \<alpha>_def using Inf_greatest by (metis (hide_lams, mono_tags) ereal_less_eq(3) image_iff)
                    have "y \<le> a" unfolding \<alpha>_def by (metis `ereal y \<le> \<alpha>` a ereal_less_eq(3))
                    thus False using y by auto
                  qed
                qed
                thus ?thesis by auto
              qed
            } note 1 = this
            { assume "\<beta> = -\<infinity>"
              hence "S = {}" unfolding \<beta>_def using Sup_eq_MInfty
                by (metis MInfty_neq_ereal(1) \<alpha>_def a cInf_singleton empty_is_image)
              thus ?thesis by auto
            }
          next
            assume "\<alpha> = \<infinity>"
            hence "S = {}" using Inf_eq_PInfty
              by (metis PInfty_neq_ereal(1) \<alpha>_def empty_is_image image_iff insertI1)
            thus ?thesis by auto
          next
            assume \<alpha>: "\<alpha> = -\<infinity>"
            show ?thesis
            proof (rule ereal_cases[of \<beta>])
              fix b :: real assume b: "\<beta> = ereal b"
              show ?thesis
              proof (cases "b \<in> S")
                assume "b \<in> S"
                hence "S = {..b}"
                  apply auto
                  using b Sup_upper unfolding \<beta>_def apply (metis ereal_less_eq(3) imageI)
                  using asm \<alpha> Inf_real_set_eq_MInfty by (metis \<alpha>_def less_imp_le)
                thus ?thesis by auto
              next
                assume "b \<notin> S"
                hence "S = {..<b}"
                  apply auto
                  using asm b Sup_upper unfolding \<beta>_def apply (metis image_eqI less_ereal.simps(1) not_le)
                proof -
                  fix x :: real assume x: "x < b"
                  have "\<exists>y. x < y \<and> y < b" using x dense by auto
                  then guess y .. note y = this
                  from Inf_real_set_eq_MInfty \<alpha> have "\<exists>z\<in>S. z < x" unfolding \<alpha>_def by auto
                  then guess z .. note z = this
                  show "x \<in> S"
                  proof (rule ccontr)
                    assume xS: "x \<notin> S"
                    hence "\<And>z. z \<in> S \<Longrightarrow> z \<le> y" using asm x y z xS by (metis dual_order.strict_trans1 le_cases le_less)
                    hence "\<beta> \<le> y" unfolding \<beta>_def using Sup_least by (metis (hide_lams, mono_tags) ereal_less_eq(3) image_iff)
                    have "b \<le> y" unfolding \<beta>_def by (metis `\<beta> \<le> ereal y` b ereal_less_eq(3)) 
                    thus False using y by auto
                  qed
                qed
                thus ?thesis by auto
              qed
            next
              assume \<beta>: "\<beta> = \<infinity>"
              have "S = UNIV"
              proof auto
                fix x :: real
                from \<beta> Sup_real_set_eq_PInfty have "\<exists>z\<in>S. x < z" unfolding \<beta>_def by auto
                then guess z .. note z = this
                from \<alpha> Inf_real_set_eq_MInfty have "\<exists>y\<in>S. y < x" unfolding \<alpha>_def by auto
                then guess y ..
                thus "x \<in> S" using asm z by (metis le_less_linear not_less_iff_gr_or_eq)
              qed
              thus ?thesis by auto
            next
              assume \<beta>: "\<beta> = -\<infinity>"
              hence "S = {}" using Sup_eq_MInfty
                by (metis MInfty_neq_ereal(1) \<beta>_def empty_is_image image_iff insertI1)
              thus ?thesis by auto
            qed
          qed
        qed
*)
lemma real_interval_borel_measurable:
  assumes "is_interval (S::real set)"
  shows "S \<in> sets borel"
proof -
  from assms is_real_interval have "\<exists>a b::real. S = {} \<or> S = UNIV \<or> S = {..<b} \<or> S = {..b} \<or>
    S = {a<..} \<or> S = {a..} \<or> S = {a<..<b} \<or> S = {a<..b} \<or> S = {a..<b} \<or> S = {a..b}" by auto
  then guess a ..
  then guess b ..
  thus ?thesis by (metis atLeastAtMost_borel atLeastLessThan_borel atMost_borel eucl_ivals(5)
    greaterThanAtMost_borel greaterThanLessThan_borel greaterThan_borel lessThan_borel sets.empty_sets
    space_in_borel)
qed

(* Should work for more general types than reals? *)
lemma borel_measurable_mono_fnc:
  fixes f :: "real \<Rightarrow> real"
  assumes "mono f"
  shows "f \<in> borel_measurable borel"
proof (subst borel_measurable_iff_ge, auto simp add:)
  fix a :: real
  have "is_interval {w. a \<le> f w}" using is_interval_1 assms(1) order.trans unfolding mono_def by (smt mem_Collect_eq)
  thus "{w. a \<le> f w} \<in> sets borel" using real_interval_borel_measurable by auto  
qed

(*
lemma continuous_at_right_real_mono_on_open_interval: 
  fixes f a b c
  assumes nondecF: "mono_on f {a<..<b}" and c: "c \<in> {a<..<b}"
  shows "(continuous (at_right (c :: real)) f) = (\<forall>\<epsilon> > 0. \<exists>\<delta> > 0. f (c + \<delta>) - f c < \<epsilon>)"
sorry
*)
(**
  apply (auto simp add: continuous_within_eps_delta dist_real_def greaterThan_def)
  apply (drule_tac x = \<epsilon> in spec, auto)
  apply (drule_tac x = "a + d / 2" in spec)
  apply (subst (asm) abs_of_nonneg)
  apply (auto intro: nondecF simp add: field_simps)
  apply (rule_tac x = "d / 2" in exI)
  apply (auto simp add: field_simps)
  apply (drule_tac x = e in spec, auto)
  apply (rule_tac x = delta in exI, auto)
  apply (subst abs_of_nonneg)
  apply (auto intro: nondecF simp add: field_simps)
  apply (rule le_less_trans)
  prefer 2 apply assumption
by (rule nondecF, auto) **)

(***
(* Proof of Skorohod in Billingsley uses only borel subsets of {0<..<1}, so this is probably not
   wanted there. *)
lemma borel_measurable_mono_AE_fnc:
  fixes M :: "real measure" fixes f g :: "real \<Rightarrow> real"
  assumes "mono g" "AE x in M. f x = g x"
  shows "f \<in> borel_measurable (completion M)"
sorry
***)

end