1. Procedure to Update Investor KYC Status:
This procedure allows users to update an investor's KYC (Know Your Customer) status.

CREATE OR REPLACE PROCEDURE update_investor_kyc (
  p_investor_id IN NUMBER,
  p_new_kyc_status IN VARCHAR2(20)
)
IS
BEGIN
  UPDATE INVESTORS
  SET kyc_status = p_new_kyc_status
  WHERE investor_id = p_investor_id;

  DBMS_OUTPUT.PUT_LINE('KYC status updated successfully for investor ID: ' || p_investor_id);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Investor with ID ' || p_investor_id || ' not found.');
END;
/

———USE:-

BEGIN
  update_investor_kyc(1001, 'Verified'); -- Update KYC for investor ID 1001
END;
/



2. Function to Calculate Total Investment per Investor:-
This function calculates the total investment amount for a specific investor.

CREATE OR REPLACE FUNCTION get_total_investment(p_investor_id NUMBER) RETURN NUMBER
IS
  v_total_investment NUMBER(15, 2);
BEGIN
  SELECT SUM(amount)
  INTO v_total_investment
  FROM TRANSACTIONS
  WHERE investor_id = p_investor_id;

  RETURN v_total_investment;
END;
/

———USE:-

DECLARE
  investor_id NUMBER := 1002;
  total_investment NUMBER(15, 2);
BEGIN
  total_investment := get_total_investment(investor_id);

  DBMS_OUTPUT.PUT_LINE('Total investment for investor ID ' || investor_id || ': ' || total_investment);
END;
/

3. Trigger to Update NAV on Scheme Transaction:
This trigger automatically updates the Net Asset Value (NAV) of a scheme whenever a transaction occurs for that scheme.

CREATE OR REPLACE TRIGGER update_nav_on_transaction
AFTER INSERT OR UPDATE ON TRANSACTIONS
FOR EACH ROW
DECLARE
  v_scheme_id NUMBER;
  v_old_nav NUMBER(15, 2);
  v_new_nav NUMBER(15, 2);
  v_total_investment NUMBER(15, 2);
  v_total_units NUMBER(15, 2);
BEGIN
  -- Get scheme ID from the new transaction row
  v_scheme_id := :NEW.scheme_id;

  -- Calculate total investment for the scheme
  SELECT SUM(amount) INTO v_total_investment
  FROM TRANSACTIONS
  WHERE scheme_id = v_scheme_id;

  -- Assuming there's a table for scheme details (needs modification based on your schema)
  SELECT nav INTO v_old_nav FROM SCHEME_DETAILS WHERE scheme_id = v_scheme_id;

  -- Calculate total number of units based on scheme details (modify based on your schema)
  v_total_units := v_total_investment / v_old_nav;

  -- Calculate new NAV
  v_new_nav := v_total_investment / v_total_units;

  -- Update NAV in SCHEME_DETAILS table (modify based on your schema)
  UPDATE SCHEME_DETAILS
  SET nav = v_new_nav
  WHERE scheme_id = v_scheme_id;
END;
/
