module FiremenHelper

  def grade_and_name(args)
    result = ""

    if args.size == 1
      fireman = args[:fireman]
      result = grade_and_name_to_str(fireman.firstname, fireman.lastname, fireman.grade)
    else
      firstname = args[:firstname]
      lastname = args[:lastname]
      grade = args[:grade]
      result = grade_and_name_to_str(firstname, lastname, grade)
    end
    result
  end

  def active_accordion(fireman)
    # if grade is set, we use it for default category
    if !fireman.current_grade.blank?
      category = Grade::GRADE_CATEGORY_MATCH[fireman.current_grade.kind]
    elsif fireman.status == Fireman::STATUS['JSP']
      category = Grade::GRADE_CATEGORY['JSP']
    end

    case category
      when Grade::GRADE_CATEGORY['Médecin']
        result = 0
      when Grade::GRADE_CATEGORY['Infirmier']
        result = 1
      when Grade::GRADE_CATEGORY['Officier']
        result = 2
      when Grade::GRADE_CATEGORY['Sous-officier']
        result = 3
      when Grade::GRADE_CATEGORY['Homme du rang']
        result = 4
      when Grade::GRADE_CATEGORY['JSP']
        result = 5
      else
        result = 4
    end
    result
  end

  def ratio_interventions(nb_interventions, total)
    if total.to_i > 0
      result = (nb_interventions.to_i*100) / total
    else
      result = 0
    end
    result
  end

  private

  def grade_and_name_to_str(firstname, lastname, grade)
    result = ""
    if !(grade.blank?)
      result += Grade::GRADE.key(grade) + " "
    end
    result += firstname + " " + lastname
    result
  end

end
