
# Just type "make" to generate one vplan (CSV format) per block

EXCEL_INPUT = test_description.xlsx
CONFIG      = cfg_excel.yaml

csvs: $(CONFIG) $(EXCEL_INPUT)
	spec_to_vplan --cfg $(CONFIG) --infile $(EXCEL_INPUT) --informat excel --outformat csv

clean:
	rm -f *.csv
