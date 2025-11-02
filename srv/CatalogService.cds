using {anubhav.db} from '../db/datamodel';
using {cappo.cds} from '../db/CDSViews';


service CatalogService @(path: 'CatalogService') {

     @Capabilities: {
          Insertable,
          Deletable: false
     }
     entity BusinessPartnerSet               as projection on db.master.businesspartner;

     entity AddressSet                       as projection on db.master.address;

     // @readonly
     entity EmployeeSet                      as projection on db.master.employees;

     entity PurchaseOrderItems               as projection on db.transaction.poitems;
     function getOrderDefault() returns POs;
     entity POs @(odata.draft.enabled: true, Common.DefaultValuesFunction: 'getOrderDefault') as
          projection on db.transaction.purchaseorder {
               *,
               case
                    OVERALL_STATUS

                    when 'N'
                         then 'New'

                    when 'P'
                         then 'Pending'

                    when 'D'
                         then 'Delivered'

                    when 'A'
                         then 'Approved'

                    when 'X'
                         then 'Rejected'

               end                 as OverallStatus : String(10),

               case
                    OVERALL_STATUS

                    when 'N'
                         then 2

                    when 'P'
                         then 2

                    when 'D'
                         then 3

                    when 'A'
                         then 3

                    when 'X'
                         then 1

               end                 as IconColor     : Integer,
               round(GROSS_AMOUNT) as GROSS_AMOUNT  : Decimal(10, 2),
               Items                                : redirected to PurchaseOrderItems
          }
          actions {
               action   boost();
               function largestOrder() returns array of POs;
               action setOrderStatus() returns POs;
          };

     entity CProductValuesView               as projection on cds.CDSViews.CProductValuesView;

}
