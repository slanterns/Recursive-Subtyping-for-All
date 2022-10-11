Set Implicit Arguments.
Require Import Metalib.Metatheory.
Require Import Program.Equality.
Require Export Infrastructure.

Lemma WF_type: forall E T,
    WF E T -> type T.
Proof with auto.
  intros.
  induction H...
  apply type_all with (L:=L)...
  apply type_all_lb with (L:=L)...
  apply type_mu with (L:=L)...
Qed.


Lemma WF_weakening: forall E1 E2 T E,
    WF (E1 ++ E2) T ->
    WF (E1 ++ E ++ E2) T.
Proof with eauto.
  intros.
  generalize dependent E.
  dependent induction H;intros...
  -
    apply WF_all with (L:=L)...
    intros.
    rewrite_alist (([(X, bind_sub T1)] ++ E1) ++ E ++ E2).
    apply H1...
  -
    apply WF_all_lb with (L:=L)...
    intros.
    rewrite_alist (([(X, bind_sub_lb T1)] ++ E1) ++ E ++ E2).
    apply H1...
  -
    apply WF_rec with (L:=L)...
    intros.
    rewrite_alist (([(X, bind_sub typ_top)] ++ E1) ++ E ++ E2).
    apply H0...
    intros.
    rewrite_alist (([(X, bind_sub typ_top)] ++ E1) ++ E ++ E2).
    apply H2...
Qed.

Lemma WF_narrowing : forall V U T E F X,
  WF (F ++ X ~ bind_sub V ++ E) T ->
  WF (F ++ X ~ bind_sub U ++ E) T.
Proof with eauto.
  intros.
  dependent induction H;try solve [analyze_binds H;eauto]...
  -
    apply WF_all with (L:=L)...
    intros.
    rewrite_alist (([(X0, bind_sub T1)] ++ F) ++ [(X, bind_sub U)] ++ E)...
    eapply H1 with (V0:=V)...
  -
    apply WF_all_lb with (L:=L)...
    intros.
    rewrite_alist (([(X0, bind_sub_lb T1)] ++ F) ++ [(X, bind_sub U)] ++ E)...
    eapply H1 with (V0:=V)...
  -
    apply WF_rec with (L:=L);intros...
    rewrite_alist (([(X0, bind_sub typ_top)] ++ F) ++ [(X, bind_sub U)] ++ E)...
    eapply H0 with (V0:=V)...
    rewrite_alist (([(X0, bind_sub typ_top)] ++ F) ++ [(X, bind_sub U)] ++ E)...
    eapply H2 with (V0:=V)...
Qed.


Lemma WF_narrowing_lb : forall V U T E F X,
  WF (F ++ X ~ bind_sub_lb V ++ E) T ->
  WF (F ++ X ~ bind_sub_lb U ++ E) T.
Proof with eauto.
  intros.
  dependent induction H;try solve [analyze_binds H;eauto]...
  -
    apply WF_all with (L:=L)...
    intros.
    rewrite_alist (([(X0, bind_sub T1)] ++ F) ++ [(X, bind_sub_lb U)] ++ E)...
    eapply H1 with (V0:=V)...
  -
    apply WF_all_lb with (L:=L)...
    intros.
    rewrite_alist (([(X0, bind_sub_lb T1)] ++ F) ++ [(X, bind_sub_lb U)] ++ E)...
    eapply H1 with (V0:=V)...
  -
    apply WF_rec with (L:=L);intros...
    rewrite_alist (([(X0, bind_sub typ_top)] ++ F) ++ [(X, bind_sub_lb U)] ++ E)...
    eapply H0 with (V0:=V)...
    rewrite_alist (([(X0, bind_sub typ_top)] ++ F) ++ [(X, bind_sub_lb U)] ++ E)...
    eapply H2 with (V0:=V)...
Qed.



Lemma subst_tt_open_tt_twice: forall X X0 A A0,
    X <> X0 -> type A0 ->
      (subst_tt X A0 (open_tt A (typ_label X0 (open_tt A X0)))) =
      (open_tt (subst_tt X A0 A) (typ_label X0 (open_tt (subst_tt X A0 A) X0))).
Proof with auto.
  intros.
  rewrite subst_tt_open_tt...
  f_equal...
  simpl...
  f_equal...
  rewrite subst_tt_open_tt_var...
Qed.  
      
Lemma subst_tt_wf : forall E A B X,
    WF E A ->
    WF E B ->
    WF E (subst_tt X A B).
Proof with auto.
  intros.
  generalize dependent A.
  induction H0;intros;simpl...
  -
    destruct (X0==X)...
    apply WF_var with (U:=U)...
  -
    destruct (X0==X)...
    apply WF_var_lb with (U:=U)...
  -
    apply WF_all with (L:=L \u fv_tt A \u {{X}})...
    intros.
    rewrite subst_tt_open_tt_var...
    add_nil.
    apply WF_narrowing with (V:=T1)...
    apply H1...
    add_nil.
    apply WF_weakening...
    apply WF_type in H2...
  -
    apply WF_all_lb with (L:=L \u fv_tt A \u {{X}})...
    intros.
    rewrite subst_tt_open_tt_var...
    add_nil.
    apply WF_narrowing_lb with (V:=T1)...
    apply H1...
    add_nil.
    apply WF_weakening...
    apply WF_type in H2...
  -
    apply WF_rec with (L:=L \u fv_tt A \u {{X}});intros...
    rewrite subst_tt_open_tt_var...
    apply H0...
    add_nil.
    apply WF_weakening...
    apply WF_type in H3...
    rewrite <- subst_tt_open_tt_twice...
    apply H2...
    add_nil.
    apply WF_weakening...
    apply WF_type in H3...
Qed.

Lemma binds_map_free: forall F X  Y U  P,
    In (X, bind_sub U) F ->
    X <> Y ->
    In (X, bind_sub (subst_tt Y P U)) (map (subst_tb Y P) F).
Proof with auto.
  induction F;intros...
  apply in_inv in H.
  destruct H...
  -
    destruct a.
    inversion H;subst.
    simpl...
  -
    simpl...
Qed.


Lemma binds_map_free_lb: forall F X  Y U  P,
    In (X, bind_sub_lb U) F ->
    X <> Y ->
    In (X, bind_sub_lb (subst_tt Y P U)) (map (subst_tb Y P) F).
Proof with auto.
  induction F;intros...
  apply in_inv in H.
  destruct H...
  -
    destruct a.
    inversion H;subst.
    simpl...
  -
    simpl...
Qed.
    
  
Lemma subst_tb_wf : forall F Q E Z P T,
  WF (F ++ Z ~ Q ++ E) T ->
  WF E P ->
  WF (map (subst_tb Z P) F ++ E) (subst_tt Z P T).
Proof with eauto.
  intros.
  generalize dependent P.
  dependent induction H;intros;simpl in *...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var with (U:=(subst_tt Z P U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var_lb with (U:=(subst_tt Z P U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free_lb...
  -
    apply WF_all with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub T1 ++ F) ++ E).
    apply H1 with (Q0:=Q)...
    apply WF_type in H2...
  -
    apply WF_all_lb with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub_lb T1 ++ F) ++ E).
    apply H1 with (Q0:=Q)...
    apply WF_type in H2...
  -
    apply WF_rec with (L:=L \u {{Z}});intros...
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub typ_top ++ F) ++ E).
    apply H0 with (Q0:=Q)...
    apply WF_type in H3...
    rewrite <- subst_tt_open_tt_twice...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub typ_top ++ F) ++ E).
    apply H2 with (Q0:=Q)...
    apply WF_type in H3...

Qed.

Lemma subst_tb_wf2 : forall F Q E Z P T,
  WF (F ++ Z ~ Q ++ E) T ->
  WF (Z ~ Q ++ E) P ->
  WF (map (subst_tb Z P) F ++ Z~Q ++ E) (subst_tt Z P T).
Proof with eauto.
  intros.
  generalize dependent P.
  dependent induction H;intros;simpl in *...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var with (U:=(subst_tt Z P U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var_lb with (U:=(subst_tt Z P U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free_lb...
  -
    apply WF_all with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub T1 ++ F) ++ (Z,Q):: E).
    apply H1 with (Q0:=Q)...
    apply WF_type in H2...
  -
    apply WF_all_lb with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub_lb T1 ++ F) ++ (Z,Q):: E).
    apply H1 with (Q0:=Q)...
    apply WF_type in H2...
  -
    apply WF_rec with (L:=L \u {{Z}});intros...
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub typ_top ++ F) ++ (Z,Q)::E).
    apply H0 with (Q0:=Q)...
    apply WF_type in H3...
    rewrite <- subst_tt_open_tt_twice...
    rewrite_env (map (subst_tb Z P) (X ~ bind_sub typ_top ++ F) ++ (Z,Q)::E).
    apply H2 with (Q0:=Q)...
    apply WF_type in H3...
Qed.


Lemma subst_tb_wf3 : forall F  E Z P T S,
  WF (F ++ Z ~ bind_sub S ++ E) T ->
  WF E P ->
  WF (map (subst_tb Z S) F ++ E) (subst_tt Z P T).
Proof with eauto.
  intros.
  generalize dependent P.
  dependent induction H;intros;simpl in *...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var with (U:=(subst_tt Z S U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var_lb with (U:=(subst_tt Z S U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free_lb...
  -
    apply WF_all with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    add_nil.
    apply WF_narrowing with (V:=subst_tt Z S T1)...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub T1 ++ F) ++ E).
    apply H1 with (S0:=S)...
    apply WF_type in H2...
  -
    apply WF_all_lb with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    add_nil.
    apply WF_narrowing_lb with (V:=subst_tt Z S T1)...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub_lb T1 ++ F) ++ E).
    apply H1 with (S0:=S)...
    apply WF_type in H2...
  -
    apply WF_rec with (L:=L \u {{Z}});intros...
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub typ_top ++ F) ++ E).
    apply H0 with (S0:=S)...
    apply WF_type in H3...
    rewrite <- subst_tt_open_tt_twice...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub typ_top ++ F) ++ E).
    apply H2 with (S0:=S)...
    apply WF_type in H3...
Qed.


Lemma subst_tb_wf3_lb : forall F  E Z P T S,
  WF (F ++ Z ~ bind_sub_lb S ++ E) T ->
  WF E P ->
  WF (map (subst_tb Z S) F ++ E) (subst_tt Z P T).
Proof with eauto.
  intros.
  generalize dependent P.
  dependent induction H;intros;simpl in *...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var with (U:=(subst_tt Z S U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free...
  -
    destruct (X==Z);subst...
    add_nil.
    apply WF_weakening...
    analyze_binds H...
    apply WF_var_lb with (U:=(subst_tt Z S U))...
    unfold binds in *.
    apply In_lemmaL.
    apply binds_map_free_lb...
  -
    apply WF_all with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    add_nil.
    apply WF_narrowing with (V:=subst_tt Z S T1)...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub T1 ++ F) ++ E).
    apply H1 with (S0:=S)...
    apply WF_type in H2...
  -
    apply WF_all_lb with (L:=L \u {{Z}})...
    intros.
    rewrite subst_tt_open_tt_var...
    add_nil.
    apply WF_narrowing_lb with (V:=subst_tt Z S T1)...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub_lb T1 ++ F) ++ E).
    apply H1 with (S0:=S)...
    apply WF_type in H2...
  -
    apply WF_rec with (L:=L \u {{Z}});intros...
    rewrite subst_tt_open_tt_var...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub typ_top ++ F) ++ E).
    apply H0 with (S0:=S)...
    apply WF_type in H3...
    rewrite <- subst_tt_open_tt_twice...
    rewrite_env (map (subst_tb Z S) (X ~ bind_sub typ_top ++ F) ++ E).
    apply H2 with (S0:=S)...
    apply WF_type in H3...
Qed.



Lemma WF_renaming: forall E1 E2 X Y A T,
    WF (E1 ++ X ~ bind_sub T ++ E2) A ->
    Y \notin {{X}} \u fv_tt A ->
    WF (map (subst_tb X Y) E1 ++ Y ~ bind_sub T ++ E2) (subst_tt X Y A).
Proof with auto.
  intros.
  dependent induction H;simpl in *...
  -
    destruct (X0==X)...
    apply WF_var with (U:=T)...
    analyze_binds H...
    apply WF_var with (U:=subst_tt X Y U)...
    apply In_lemmaL.
    apply  binds_map_free...
    apply WF_var with (U:=U)...
  -
    destruct (X0==X)...
    apply WF_var with (U:=T)...
    analyze_binds H...
    apply WF_var_lb with (U:=subst_tt X Y U)...
    apply In_lemmaL.
    apply  binds_map_free_lb...
    apply WF_var_lb with (U:=U)...
  -
    apply WF_all with (L:=L \u {{X}} \u {{Y}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub T1 ++ E1)) ++ (Y, bind_sub T) :: E2).
    apply H1...
    solve_notin.
  - apply WF_all_lb with (L:=L \u {{X}} \u {{Y}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub_lb T1 ++ E1)) ++ (Y, bind_sub T) :: E2).
    apply H1...
    solve_notin.
  -
    apply WF_rec with (L:=L \u {{X}} \u {{Y}});intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub typ_top ++ E1)) ++ (Y, bind_sub T) :: E2).
    apply H0...
    solve_notin.
    rewrite <- subst_tt_open_tt_twice...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub typ_top ++ E1)) ++ (Y, bind_sub T) :: E2).
    apply H2...
    solve_notin.
Qed.


Lemma WF_renaming_lb: forall E1 E2 X Y A T,
    WF (E1 ++ X ~ bind_sub_lb T ++ E2) A ->
    Y \notin {{X}} \u fv_tt A ->
    WF (map (subst_tb X Y) E1 ++ Y ~ bind_sub_lb T ++ E2) (subst_tt X Y A).
Proof with auto.
  intros.
  dependent induction H;simpl in *...
  -
    destruct (X0==X)...
    apply WF_var_lb with (U:=T)...
    analyze_binds H...
    apply WF_var with (U:=subst_tt X Y U)...
    apply In_lemmaL.
    apply  binds_map_free...
    apply WF_var with (U:=U)...
  -
    destruct (X0==X)...
    apply WF_var_lb with (U:=T)...
    analyze_binds H...
    apply WF_var_lb with (U:=subst_tt X Y U)...
    apply In_lemmaL.
    apply  binds_map_free_lb...
    apply WF_var_lb with (U:=U)...
  -
    apply WF_all with (L:=L \u {{X}} \u {{Y}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub T1 ++ E1)) ++ (Y, bind_sub_lb T) :: E2).
    apply H1...
    solve_notin.
  - apply WF_all_lb with (L:=L \u {{X}} \u {{Y}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub_lb T1 ++ E1)) ++ (Y, bind_sub_lb T) :: E2).
    apply H1...
    solve_notin.
  -
    apply WF_rec with (L:=L \u {{X}} \u {{Y}});intros.
    rewrite subst_tt_open_tt_var...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub typ_top ++ E1)) ++ (Y, bind_sub_lb T) :: E2).
    apply H0...
    solve_notin.
    rewrite <- subst_tt_open_tt_twice...
    rewrite_env ((map (subst_tb X Y) (X0 ~ bind_sub typ_top ++ E1)) ++ (Y, bind_sub_lb T) :: E2).
    apply H2...
    solve_notin.
Qed.


    
Lemma sub_regular : forall E A B,
    sub E A B -> wf_env E /\ WF E A /\ WF E B.
Proof with auto.
  intros.
  induction H;destruct_hypos...
  -
    repeat split...
    apply WF_var with (U:=U)...
  -
    repeat split...
    apply WF_var_lb with (U:=U)...
  -
    repeat split...
    apply WF_all with (L:=L);intros...
    rewrite_env (nil ++ X ~ bind_sub S1 ++ E).
    eapply WF_narrowing with (V:=S2)...
    eapply H2...
    apply WF_all with (L:=L);intros...
    eapply H2...
  -
    repeat split...
    apply WF_all_lb with (L:=L);intros...
    rewrite_env (nil ++ X ~ bind_sub_lb S1 ++ E).
    eapply WF_narrowing_lb with (V:=S2)...
    eapply H2...
    apply WF_all_lb with (L:=L);intros...
    eapply H2...
  -
    split.    
    pick fresh X.
    specialize_x_and_L X L.
    destruct_hypos.
    dependent destruction H2...
    split...
    +
      apply WF_rec with (L:=L \u fv_tt A1 \u fv_tt A2);intros...
      eapply H2...
    +
      apply WF_rec with (L:=L \u fv_tt A1 \u fv_tt A2);intros...
      eapply H2...
Qed.
    

Ltac get_well_form :=
    repeat match goal with
    | [ H : sub _ _ _ |- _ ] => apply sub_regular in H;destruct_hypos   
           end.

Ltac get_type :=
    repeat match goal with
           | [ H : sub _ _ _ |- _ ] => get_well_form
           | [ H : WF _ _ |- _ ] => apply WF_type in H
           end.

Lemma Reflexivity: forall E A,
    WF E A ->
    wf_env E ->
    sub E A A.
Proof with auto.
  intros.
  induction H...
  -
    constructor...
    apply WF_var with (U:=U)...
  -
    constructor...
    apply WF_var_lb with (U:=U)...
  -
    apply sa_all with (L:=L \u dom E \u fv_env E \u fl_env E)...
  -
    apply sa_all_lb with (L:=L \u dom E \u fv_env E \u fl_env E)...
  -
    apply sa_rec with (L:=L \u dom E \u fv_env E \u fl_env E)...
Qed.

    
  
Lemma Sub_weakening: forall E1 E2 A B E,
    sub (E1 ++ E2) A B ->
    wf_env (E1 ++ E ++ E2) ->
    sub (E1 ++ E ++ E2) A B.
Proof with eauto using WF_weakening.
  intros.
  generalize dependent E.
  dependent induction H;intros...
  -
    apply sa_all with (L:=L \u dom E1 \u dom E2 \u dom E \u fv_env (E1++E++E2) \u fl_env (E1++E++E2))...
    intros.
    rewrite_alist (([(X, bind_sub S2)] ++ E1) ++ E ++ E2).
    apply H2...
    get_well_form.
    rewrite_alist ([(X, bind_sub S2)] ++ E1 ++ E ++ E2)...
  -
    apply sa_all_lb with (L:=L \u dom E1 \u dom E2 \u dom E \u fv_env (E1++E++E2) \u fl_env (E1++E++E2))...
    intros.
    rewrite_alist (([(X, bind_sub_lb S2)] ++ E1) ++ E ++ E2).
    apply H2...
    get_well_form.
    rewrite_alist ([(X, bind_sub_lb S2)] ++ E1 ++ E ++ E2)...
  -
    apply sa_rec with (L:=L \u dom E1 \u dom E2 \u dom E \u fv_env (E1++E++E2) \u fl_env (E1++E++E2));intros...
    rewrite_alist (([(X, bind_sub typ_top)] ++ E1) ++ E ++ E2)...
    apply WF_weakening...
    apply H...
    rewrite_alist (([(X, bind_sub typ_top)] ++ E1) ++ E ++ E2).
    apply WF_weakening...
    apply H0...
    rewrite_alist (([(X, bind_sub typ_top)] ++ E1) ++ E ++ E2).
    apply H2...
    rewrite_alist ([(X, bind_sub typ_top)] ++ E1 ++ E ++ E2)...
Qed.

Lemma uniq_from_wf_env : forall E,
  wf_env E ->
  uniq E.
Proof.
  intros E H; induction H; auto.
Qed.

Lemma in_binds: forall x a U x0,
    a `in` dom (x ++ (a, bind_sub U) :: x0).
Proof with auto.
  induction x;intros...
  simpl...
  simpl...
  destruct a...
Qed.


Lemma in_binds_lb: forall x a U x0,
    a `in` dom (x ++ (a, bind_sub_lb U) :: x0).
Proof with auto.
  induction x;intros...
  simpl...
  simpl...
  destruct a...
Qed.

Lemma union_subset_6: forall A B C,
    A [<=] B ->
    A [<=] union B C.
Proof with auto.
  intros.
  unfold "[<=]" in *.
  intros.
  apply H in H0...
Qed.

Lemma union_subset_7: forall A B C,
    union A B [<=] C ->
    A [<=] C /\ B [<=] C.
Proof with auto.
  intros.
  unfold "[<=]" in *.
  split;intros...
Qed.  

Lemma fv_open_tt_notin: forall T S (X:atom),
    X \notin fv_tt T ->
    fv_tt T [<=] S -> 
    fv_tt (open_tt T X) [<=] add X S.
Proof with auto.
  intros.
  unfold open_tt.
  generalize 0.
  induction T;intros;simpl in *;try solve [apply AtomSetProperties.subset_add_2;apply KeySetProperties.subset_empty]...
  -
    destruct (n0==n);simpl...
    unfold "[<=]".
    intros...
    apply AtomSetNotin.D.F.singleton_iff in H1...
    apply KeySetProperties.subset_empty.
  -
    apply AtomSetProperties.subset_add_2...
  -
    apply notin_union in H.
    apply union_subset_7 in H0.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
  -
    apply notin_union in H.
    apply union_subset_7 in H0.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...
  -
    apply notin_union in H.
    apply union_subset_7 in H0.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
Qed.

Lemma fv_open_tt_notin_inv: forall T S (X:atom),
    X \notin fv_tt T ->
    fv_tt (open_tt T X) [<=] add X S ->
    fv_tt T [<=] S.
Proof with auto.
  intro T.
  unfold open_tt in *.
  generalize 0.
  induction T;intros;simpl in *;try solve [apply KeySetProperties.subset_empty]...
  -
    unfold "[<=]" in *.
    intros...
    apply AtomSetNotin.D.F.singleton_iff in H1...
    subst.
    assert (a0 `in` singleton a0) by auto.
    specialize (H0 a0 H1)...
    apply AtomSetImpl.add_3 in H0...
  -
    apply union_subset_7 in H0.
    apply notin_union in H.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
    apply IHT1 with (X:=X) (n:=n)...
    apply IHT2 with (X:=X) (n:=n)...
  -
    apply union_subset_7 in H0.
    apply notin_union in H.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
    apply IHT1 with (X:=X) (n:=n)...
    apply IHT2 with (X:=X) (n:=(Datatypes.S n))...
  -
    apply union_subset_7 in H0.
    apply notin_union in H.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
    apply IHT1 with (X:=X) (n:=n)...
    apply IHT2 with (X:=X) (n:=(Datatypes.S n))...
  -
    apply IHT with (X:=X) (n:=(Datatypes.S n))...
  -
    apply IHT with (X:=X) (n:=n)...
Qed.

Lemma fl_open_tt_notin_inv: forall T S (X:atom),
    X \notin fv_tt T \u fl_tt T ->
    fl_tt (open_tt T X) [<=] add X S ->
    fl_tt T [<=] S.
Proof with auto.
  intro T.
  unfold open_tt in *.
  generalize 0.
  induction T;intros;simpl in *;try solve [apply KeySetProperties.subset_empty]...
  -
    apply union_subset_7 in H0.
    apply notin_union in H.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
    apply IHT1 with (X:=X) (n:=n)...
    apply IHT2 with (X:=X) (n:=n)...
  -
    apply union_subset_7 in H0.
    apply notin_union in H.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
    apply IHT1 with (X:=X) (n:=n)...
    apply IHT2 with (X:=X) (n:=(Datatypes.S n))...
  -
    apply union_subset_7 in H0.
    apply notin_union in H.
    destruct_hypos.
    apply KeySetProperties.union_subset_3...    
    apply IHT1 with (X:=X) (n:=n)...
    apply IHT2 with (X:=X) (n:=(Datatypes.S n))...
  -
    apply IHT with (X:=X) (n:=(Datatypes.S n))...
  -
    apply KeySetProperties.union_subset_3...
    apply union_subset_7 in H0.
    destruct H0.
    unfold "[<=]" in *.
    intros.
    assert (Ht:=H2).
    apply H0 in H2.
    apply AtomSetProperties.FM.singleton_iff in Ht.
    subst.
    apply AtomSetImpl.add_3 in H2...
    apply IHT with (X:=X) (n:=n)...
    apply union_subset_7 in H0.
    destruct_hypos...    
Qed.


Lemma WF_imply_dom: forall E A,
    WF E A ->
    fv_tt A [<=] dom E.
Proof with auto.
  intros.
  induction H;simpl in *;try solve [apply KeySetProperties.subset_empty]...
  -
    unfold binds in H...
    unfold "[<=]".
    intros.
    apply KeySetFacts.singleton_iff in H0.
    subst.
    apply in_split in H.
    destruct_hypos.
    rewrite H...
    apply in_binds...
  -
    unfold binds in H...
    unfold "[<=]".
    intros.
    apply KeySetFacts.singleton_iff in H0.
    subst.
    apply in_split in H.
    destruct_hypos.
    rewrite H...
    apply in_binds_lb...
  -
    apply KeySetProperties.union_subset_3...
  -
    apply KeySetProperties.union_subset_3...
    pick fresh X.
    specialize_x_and_L X L.
    apply fv_open_tt_notin_inv in H1...
  -
    apply KeySetProperties.union_subset_3...
    pick fresh X.
    specialize_x_and_L X L.
    apply fv_open_tt_notin_inv in H1...
  -
    pick fresh X.
    specialize_x_and_L X L.
    apply fv_open_tt_notin_inv in H0...
Qed.

Lemma wf_env_cons: forall E1 E2,
    wf_env (E1++E2) ->
    wf_env E2.
Proof with auto.
  induction E1;intros...
  destruct a...
  dependent destruction H...
Qed.

Lemma fv_env_ls_dom: forall E,
    wf_env E ->
    fv_env E [<=] dom E.
Proof with auto.
  induction E;intros;simpl in *...
  -
    apply AtomSetProperties.subset_empty...
  -
    destruct a.
    destruct b.
    +
      dependent destruction H.
      apply KeySetProperties.subset_add_2...
      apply AtomSetProperties.union_subset_3...
      apply WF_imply_dom...
    +
      dependent destruction H.
      apply KeySetProperties.subset_add_2...
      apply AtomSetProperties.union_subset_3...
      apply WF_imply_dom...
    +
      dependent destruction H.
      apply KeySetProperties.subset_add_2...
      apply AtomSetProperties.union_subset_3...
      apply WF_imply_dom...
Qed.


Lemma notin_from_wf_env: forall E1 X T E2,
    wf_env (E1 ++ (X, bind_sub T) :: E2) ->
    X \notin fv_tt T \u dom E2 \u dom E1 \u fv_env E2.
Proof with auto.
  induction E1;intros...
  -
    dependent destruction H...
    apply WF_imply_dom in H0...
    apply fv_env_ls_dom in H...    
  -
    dependent destruction H...
    + simpl in *...
      apply IHE1 in H...
    + simpl in *...
      apply IHE1 in H...
    + simpl in *...
      apply IHE1 in H...
Qed.



Lemma notin_from_wf_env_lb: forall E1 X T E2,
    wf_env (E1 ++ (X, bind_sub_lb T) :: E2) ->
    X \notin fv_tt T \u dom E2 \u dom E1 \u fv_env E2.
Proof with auto.
  induction E1;intros...
  -
    dependent destruction H...
    apply WF_imply_dom in H0...
    apply fv_env_ls_dom in H...    
  -
    dependent destruction H...
    + simpl in *...
      apply IHE1 in H...
    + simpl in *...
      apply IHE1 in H...
    + simpl in *...
      apply IHE1 in H...
Qed.

Lemma WF_from_binds_typ : forall x U E,
  wf_env E ->
  binds x (bind_sub U) E ->
  WF E U.
Proof with auto.
  induction 1; intros J; analyze_binds J...
  -
    inversion BindsTacVal;subst.
    add_nil.
    apply WF_weakening...
  -
    add_nil.
    apply WF_weakening...
 -
    add_nil.
    apply WF_weakening...
 -
    add_nil.
    apply WF_weakening...
Qed.


Lemma WF_from_binds_typ_lb : forall x U E,
  wf_env E ->
  binds x (bind_sub_lb U) E ->
  WF E U.
Proof with auto.
  induction 1; intros J; analyze_binds J...
  -
    add_nil.
    apply WF_weakening...
  -
    inversion BindsTacVal;subst.
    add_nil.
    apply WF_weakening...
 -
    add_nil.
    apply WF_weakening...
 -
    add_nil.
    apply WF_weakening...
Qed.

Lemma notin_partial: forall X E1 E2,
    X \notin E2 ->
    E1 [<=] E2 ->
    X \notin E1.
Proof with auto.
  unfold "[<=]".
  intros...
Qed.
