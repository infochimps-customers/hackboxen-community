#!/usr/bin/env ruby

OFFSET = 5


genders = %w[ both male female ]
ages = %w[ total under_5 5_to_9
           10_to_14 15_to_19
           20_to_24 25_to_29
           30_to_34 35_to_39
           40_to_44 45_to_49
           50_to_54 55_to_59
           60_to_64 65_to_69
           70_to_74 75_to_79
           80_to_84 over_85 ]

def gen_mapping_entry(key, doc, idx=$idx)
  $mapfp.puts "  :#{key} => fields[#{idx}],"
  $docfp.puts "- name: #{key}"
  $docfp.puts "  doc: \"#{doc}\""
  $docfp.puts "  type: integer"
  $idx = idx + 1
end

# Open files
$mapfp = File.open("map.rb", "w")
$docfp = File.open("doc.yaml", "w")

# DPSF1 - sex and age [57]
$idx = OFFSET
genders.each { |gender|
  ages.each { |age|
    gdoc = (gender == "both") ? "" : "#{gender.capitalize} "
    gen_mapping_entry("pop_#{age}_#{gender}", "#{gdoc}Population #{age.tr("_"," ")} years")
  }
}

# DPSF2 - median age by sex [3]
gen_mapping_entry("median_age_both", "Median age of population")
gen_mapping_entry("median_age_male", "Median age of male population")
gen_mapping_entry("median_age_female", "Median age of female population")

# DPSF3 - sex for the population 16 years and over [3]
gen_mapping_entry("pop_over_16", "Population 16 years and over")
gen_mapping_entry("pop_over_16_male", "Male Population 16 years and over")
gen_mapping_entry("pop_over_16_female", "Female Population 16 years and over")

# DPSF4 - sex for the population 18 years and over [3]
gen_mapping_entry("pop_over_18", "Population 18 years and over")
gen_mapping_entry("pop_over_18_male", "Male Population 18 years and over")
gen_mapping_entry("pop_over_18_female", "Female Population 18 years and over")

# DPSF5 - sex for the population 21 years and over [3]
gen_mapping_entry("pop_over_21", "Population 21 years and over")
gen_mapping_entry("pop_over_21_male", "Male Population 21 years and over")
gen_mapping_entry("pop_over_21_female", "Female Population 21 years and over")

# DPSF6 - sex for the population 62 years and over [3]
gen_mapping_entry("pop_over_62", "Population 62 years and over")
gen_mapping_entry("pop_over_62_male", "Male Population 62 years and over")
gen_mapping_entry("pop_over_62_female", "Female Population 62 years and over")

# DPSF7 - sex for the population 65 years and over [3]
gen_mapping_entry("pop_over_65", "Population 65 years and over")
gen_mapping_entry("pop_over_65_male", "Male Population 65 years and over")
gen_mapping_entry("pop_over_65_female", "Female Population 65 years and over")

# DSPF8 - race [24]
$idx += 1  # skip race total
gen_mapping_entry("pop_one_race", "Population of one race")
gen_mapping_entry("pop_one_race_white", "Population of one race, White")
gen_mapping_entry("pop_one_race_black", "Population of one race, Black or African American")
gen_mapping_entry("pop_one_race_native", "Population of one race, American Indian and Alaska Native")
gen_mapping_entry("pop_one_race_asian", "Population of one race, Asian")
  $idx += 7  # skip asian subgroups
gen_mapping_entry("pop_one_race_pacific_islander", "Population of one race, Native Hawaiian and Other Pacific Islander")
  $idx += 4  # skip pacific subgroups
gen_mapping_entry("pop_one_race_other", "Population of one race, Other")
gen_mapping_entry("pop_two_race", "Population of Two or More Races")
gen_mapping_entry("pop_two_race_white_and_native", "Population of Two or More Races, White; American Indian and Alaska Native")
gen_mapping_entry("pop_two_race_white_and_asian", "Population of Two or More Races, White; Asian")
gen_mapping_entry("pop_two_race_white_and_black", "Population of Two or More Races, White; Black or African American")
gen_mapping_entry("pop_two_race_white_and_other", "Population of Two or More Races, White; Some Other Race")

# DSPF9 - race (total races tallied) [6]
gen_mapping_entry("pop_white", "White alone or in combination with one or more other races")
gen_mapping_entry("pop_black", "Black or African American alone or in combination with one or more other races")
gen_mapping_entry("pop_native", "American Indian and Alaska Native alone or in combination with one or more other races")
gen_mapping_entry("pop_asian", "Asian alone or in combination with one or more other races")
gen_mapping_entry("pop_pacific_islander", "Native Hawaiian and Other Pacific Islander alone or in combination with one or more other races")
gen_mapping_entry("pop_other", "Some Other Race alone or in combination with one or more other races")

# DSPF10
$idx += 7

# DSPF11
$idx += 17

# DSPF12 - relationship [20]
$idx += 1
gen_mapping_entry("pop_in_households", "Population in households")
gen_mapping_entry("pop_householder", "Householder")
gen_mapping_entry("pop_spouse", "Spouse ")
gen_mapping_entry("pop_child", "Child")
gen_mapping_entry("pop_own_child_under_18", "Own child under 18 years")
gen_mapping_entry("pop_other_relatives", "Other relatives")
gen_mapping_entry("pop_other_relatives_under_18", "Other relatives, under 18 years")
gen_mapping_entry("pop_other_relatives_65_over", "Other relatives, 65 years and over")
gen_mapping_entry("pop_non_relatives", "Nonrelatives")
gen_mapping_entry("pop_non_relatives_under_18", "Nonrelatives, under 18 years")
gen_mapping_entry("pop_non_relatives_65_over", "Nonrelatives, 65 years and over")
gen_mapping_entry("pop_non_relatives_partner", "Nonrelatives, unmarried partner")
gen_mapping_entry("pop_group_quarters", "In group quarters")
gen_mapping_entry("pop_group_quarters_inst", "In group quarters, Institutionalized population")
gen_mapping_entry("pop_group_quarters_inst_male", "In group quarters, Male Institutionalized population")
gen_mapping_entry("pop_group_quarters_inst_female", "In group quarters, Female Institutionalized population")
gen_mapping_entry("pop_group_quarters", "In group quarters")
gen_mapping_entry("pop_group_quarters_noninst", "In group quarters, Noninstitutionalized population")
gen_mapping_entry("pop_group_quarters_noninst_male", "In group quarters, Male Noninstitutionalized population")
gen_mapping_entry("pop_group_quarters_noninst_female", "In group quarters, Female Noninstitutionalized population")

# Close files
$mapfp.close
$docfp.close
