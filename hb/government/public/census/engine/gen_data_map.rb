#!/usr/bin/env ruby

$idx = 5
$dpsf = 0


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

def dpsf_increment
  $dpsf += 1
  $dpsf_sub = 1
end

def gen_mapping_entry(key, doc, last=false)
  key = "dpsf#{sprintf("%03i",$dpsf)}#{sprintf("%04i",$dpsf_sub)}"
  $mapfp.puts "  :#{key} => fields[#{$idx}]#{',' unless last}"
  $docfp.puts "  - name: \"#{key}\""
  $docfp.puts "    doc: \"#{doc}\""
  $docfp.puts "    type: integer"
  $idx += 1
  $dpsf_sub += 1
end

# Open files
$mapfp = File.open("calc_demographic_properties.rb", "w")
$mapfp.puts "def calc_demographic_properties(fields)\n  {"
$docfp = File.open("doc.yaml", "w")

# DPSF1 - sex and age [57]
dpsf_increment
genders.each { |gender|
  ages.each { |age|
    gdoc = (gender == "both") ? "" : "#{gender.capitalize} "
    gen_mapping_entry("pop_#{age}_#{gender}", "#{gdoc}Population #{age.tr("_"," ")} years")
  }
}

# DPSF2 - median age by sex [3]
dpsf_increment
gen_mapping_entry("median_age_both", "Median age of population")
  gen_mapping_entry("median_age_male", "Median age of male population")
  gen_mapping_entry("median_age_female", "Median age of female population")

# DPSF3 - sex for the population 16 years and over [3]
dpsf_increment
gen_mapping_entry("pop_over_16", "Population 16 years and over")
  gen_mapping_entry("pop_over_16_male", "Male Population 16 years and over")
  gen_mapping_entry("pop_over_16_female", "Female Population 16 years and over")

# DPSF4 - sex for the population 18 years and over [3]
dpsf_increment
gen_mapping_entry("pop_over_18", "Population 18 years and over")
  gen_mapping_entry("pop_over_18_male", "Male Population 18 years and over")
  gen_mapping_entry("pop_over_18_female", "Female Population 18 years and over")

# DPSF5 - sex for the population 21 years and over [3]
dpsf_increment
gen_mapping_entry("pop_over_21", "Population 21 years and over")
  gen_mapping_entry("pop_over_21_male", "Male Population 21 years and over")
  gen_mapping_entry("pop_over_21_female", "Female Population 21 years and over")

# DPSF6 - sex for the population 62 years and over [3]
dpsf_increment
gen_mapping_entry("pop_over_62", "Population 62 years and over")
  gen_mapping_entry("pop_over_62_male", "Male Population 62 years and over")
  gen_mapping_entry("pop_over_62_female", "Female Population 62 years and over")

# DPSF7 - sex for the population 65 years and over [3]
dpsf_increment
gen_mapping_entry("pop_over_65", "Population 65 years and over")
  gen_mapping_entry("pop_over_65_male", "Male Population 65 years and over")
  gen_mapping_entry("pop_over_65_female", "Female Population 65 years and over")

# DPSF8 - race [24]
dpsf_increment
gen_mapping_entry("", "Total population")
gen_mapping_entry("pop_one_race", "Population of one race")
gen_mapping_entry("pop_one_race_white", "Population of one race, White")
gen_mapping_entry("pop_one_race_black", "Population of one race, Black or African American")
gen_mapping_entry("pop_one_race_native", "Population of one race, American Indian and Alaska Native")
gen_mapping_entry("pop_one_race_asian", "Population of one race, Asian")
  gen_mapping_entry("", "Population of one race, Asian Indian")
  gen_mapping_entry("", "Population of one race, Chinese")
  gen_mapping_entry("", "Population of one race, Filipino")
  gen_mapping_entry("", "Population of one race, Japanese")
  gen_mapping_entry("", "Population of one race, Korean")
  gen_mapping_entry("", "Population of one race, Vietnamese")
  gen_mapping_entry("", "Population of one race, Other Asian")
gen_mapping_entry("pop_one_race_pacific_islander", "Population of one race, Native Hawaiian and Other Pacific Islander")
  gen_mapping_entry("", "Population of one race, Native Hawaiian")
  gen_mapping_entry("", "Population of one race, Guamanian or Chamorro")
  gen_mapping_entry("", "Population of one race, Samoan")
  gen_mapping_entry("", "Population of one race, Other Pacific Islander")
gen_mapping_entry("pop_one_race_other", "Population of one race, Other")
gen_mapping_entry("pop_two_race", "Population of Two or More Races")
gen_mapping_entry("pop_two_race_white_and_native", "Population of Two or More Races, White; American Indian and Alaska Native")
gen_mapping_entry("pop_two_race_white_and_asian", "Population of Two or More Races, White; Asian")
gen_mapping_entry("pop_two_race_white_and_black", "Population of Two or More Races, White; Black or African American")
gen_mapping_entry("pop_two_race_white_and_other", "Population of Two or More Races, White; Some Other Race")

# DPSF9 - race (total races tallied) [6]
dpsf_increment
gen_mapping_entry("pop_white", "White alone or in combination with one or more other races")
gen_mapping_entry("pop_black", "Black or African American alone or in combination with one or more other races")
gen_mapping_entry("pop_native", "American Indian and Alaska Native alone or in combination with one or more other races")
gen_mapping_entry("pop_asian", "Asian alone or in combination with one or more other races")
gen_mapping_entry("pop_pacific_islander", "Native Hawaiian and Other Pacific Islander alone or in combination with one or more other races")
gen_mapping_entry("pop_other", "Some Other Race alone or in combination with one or more other races")

# DPSF10
dpsf_increment
gen_mapping_entry("", "Total population")
gen_mapping_entry("", "Hispanic or Latino")
  gen_mapping_entry("", "Hispanic or Latino, Mexican")
  gen_mapping_entry("", "Hispanic or Latino, Puerto Rican")
  gen_mapping_entry("", "Hispanic or Latino, Cuban")
  gen_mapping_entry("", "Hispanic or Latino, Other")
gen_mapping_entry("", "Not Hispanic or Latino")

# DPSF11
dpsf_increment
gen_mapping_entry("", "Total population")
gen_mapping_entry("", "Hispanic or Latino")
  gen_mapping_entry("", "Hispanic or Latino, White Alone")
  gen_mapping_entry("", "Hispanic or Latino, Black or African American")
  gen_mapping_entry("", "Hispanic or Latino, American Indian and Alaska Native alone")
  gen_mapping_entry("", "Hispanic or Latino, Asian alone")
  gen_mapping_entry("", "Hispanic or Latino, Native Hawaiian and Other Pacific Islander alone")
  gen_mapping_entry("", "Hispanic or Latino, Some Other Race alone")
  gen_mapping_entry("", "Hispanic or Latino, Two or More Races")
gen_mapping_entry("", "Not Hispanic or Latino")
  gen_mapping_entry("", "Not Hispanic or Latino, White Alone")
  gen_mapping_entry("", "Not Hispanic or Latino, Black or African American")
  gen_mapping_entry("", "Not Hispanic or Latino, American Indian and Alaska Native alone")
  gen_mapping_entry("", "Not Hispanic or Latino, Asian alone")
  gen_mapping_entry("", "Not Hispanic or Latino, Native Hawaiian and Other Pacific Islander alone")
  gen_mapping_entry("", "Not Hispanic or Latino, Some Other Race alone")
  gen_mapping_entry("", "Not Hispanic or Latino, Two or More Races")

# DPSF12 - relationship [20]
dpsf_increment
gen_mapping_entry("", "Total population")
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

# DPSF13 - households by type [15]
dpsf_increment
gen_mapping_entry("", "Total households")
  gen_mapping_entry("", "Family households")
    gen_mapping_entry("", "Family households, with own children under 18")
    gen_mapping_entry("", "Family households, Husband-Wife")
    gen_mapping_entry("", "Family households, Husband-Wife, with own children under 18")
    gen_mapping_entry("", "Family households, Male householder")
    gen_mapping_entry("", "Family households, Male householder, with own children under 18")
    gen_mapping_entry("", "Family households, Female householder")
    gen_mapping_entry("", "Family households, Female householder, with own children under 18")
  gen_mapping_entry("", "Non-family households")
    gen_mapping_entry("", "Householder living alone")
    gen_mapping_entry("", "Male householder living alone")
    gen_mapping_entry("", "Male householder living alone, 65 years or older")
    gen_mapping_entry("", "Female householder living alone")
    gen_mapping_entry("", "Female householder living alone, 65 years or older")

# DPSF14 - households with individuals under 18 years [1]
dpsf_increment
gen_mapping_entry("hh_with_under_18", "households with individuals under 18 years")

# DPSF15 - households with individuals 65 years and over [1]
dpsf_increment
gen_mapping_entry("hh_with_65_over", "households with individuals 65 years and over")

# DPSF16 - average household size [1]
dpsf_increment
gen_mapping_entry("avg_hh_size", "average household size")

# DPSF17 - average family size [1]
dpsf_increment
gen_mapping_entry("avg_family_size", "average family size")

# DPSF18 - housing occupancy [9]
dpsf_increment
gen_mapping_entry("total_housing_units", "Total housing units")
  gen_mapping_entry("", "Occupied housing units")
  gen_mapping_entry("", "Vacant housing units")
    gen_mapping_entry("", "Vacant housing units, for rent")
    gen_mapping_entry("", "Vacant housing units, Rented, not occupied")
    gen_mapping_entry("", "Vacant housing units, For sale only")
    gen_mapping_entry("", "Vacant housing units, Sold, not occupied")
    gen_mapping_entry("", "Vacant housing units, For seasonal, recreational, or occasional use")
    gen_mapping_entry("", "Vacant housing units, All other")


# DPSF19 - homeowner vacancy rate [1]
dpsf_increment
gen_mapping_entry("", "Homeowner vacancy rate (percent)")

# DPSF20 - rental vacancy rate [1]
dpsf_increment
gen_mapping_entry("", "Rental vacancy rate (percent)")

# DPSF21 - housing tenure [3]
dpsf_increment
gen_mapping_entry("", "Total occupied housing units")
  gen_mapping_entry("", "Owner-occupied housing units")
  gen_mapping_entry("", "Renter-occupied housing units")

# DPSF22 - population in occupied housing units by tenure [2]
dpsf_increment
gen_mapping_entry("", "Population in Owner-occupied housing units")
gen_mapping_entry("", "Population in Renter-occupied housing units")

# DPSF23 - average household size of occupied housing units by tenure [2]
dpsf_increment
gen_mapping_entry("", "Average household size, owner-occupied")
gen_mapping_entry("", "Average household size, renter-occupied", true)

# Close files
$mapfp.puts "  }\nend"
$mapfp.close
$docfp.close
