CREATE DEFINER=`root`@`localhost` PROCEDURE `DATA_PERFORMANCE`(in INCOME_CLASS varchar(20))
BEGIN
declare budget_val double;
## target,invoice,acheived for cross sell,New,Renewal
set @cross_sell_target=(select sum(cross_Bugdet)from budgets11);
set @new_target=(select sum(New_Budget)from budgets11);
set @renewal_target=( select sum(Renewal_Budget)from budgets11);

set @invoice_val=(select sum(amount)from invoice where income_class=income_class);
set @acheived_val=((select sum(amount)from brokerage11 where income_class=income_class)+(select sum(amount) from fees11 where income_class=income_class));

if income_class="cross sell" then set budget_val=@cross_sell_target;
elseif income_class="new" then set budget_val=@new_targett;
elseif income_class="renewal" then set budget_val=@renewal_target;
else set budget_val=0;
end if;
## percentage of placed achievment
set @placed_acheivement=(select concat(format((@acheived_val/budget_val)*100,2),'%'));
## percentage of invoice achievment
set @invoice_acheivment=(select concat(format((@Invoice_val/budget_val)*100,2),'%'));
select income_class,format(budget_val,0) as  Target,format(@invoice_val,0) as invoice,
format(@acheived_val,2) as acheived,@placed_acheivement as placed_acheivement_percentage,@invoice_acheivment as invoice_acheivment_percdentage;



end