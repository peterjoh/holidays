class exports.Holidays # Requires moment.js

    # Don't instantiate directly. Use factory method below.
    constructor: ->
        @holidays  = {} # { year: [days] }
        @sunday    = 0
        @monday    = 1
        @tuesday   = 2
        @wednesday = 3
        @thursday  = 4
        @friday    = 5
        @saturday  = 6
    
    isHoliday: (date) =>
        date = moment date

        @_ensureHolidaysForYear date.year()

        for holiday in @holidays[date.year()]
            return true if date.isSame moment holiday

        return false

    getHolidaysBetween: (from, to) =>
        from = moment from
        to   = moment to
        days = []
    
        d = moment from
        while d.isBefore to
            @_ensureHolidaysForYear d.year()
            log d.toDate(), @holidays[d.year()], d.toDate() in @holidays[d.year()]
            if d.toDate() in @holidays[d.year()]
                days.push d.toDate()
            d.add 1, 'day'

        return days

    _ensureHolidaysForYear: (year) =>
        if not (year of @holidays)
            @holidays[year] = @_getHolidays year
    
    _getEasterDate: (year) =>
        month = 3
        g     = year % 19 + 1
        c     = year / 100 + 1
        x     = ( 3*c ) / 4 - 12
        y     = ( 8*c+5 ) / 25 - 5
        z     = ( 5*year ) / 4 - x - 10
        e     = ( 11*g+20+y-x ) % 30
    
        e++ if e == 24
        e++ if e == 25 and g > 11
    
        n = 44 - e
        n = n + 30 if n < 21
        p = ( n + 7 ) - (( z + n ) % 7)
    
        if p > 31
            p = p - 31
            month = 4
    
        new Date year, month-1, p

    _addWeekends: (year, holidays) =>
        start = new Date year,  0,  1
        end   = new Date year, 11, 31
        d     = moment start

        while d.isBefore(end) or d.isSame(end)
            if d.day() == @saturday or d.day() == @sunday
                if d.toDate() not in holidays
                    holidays.push d.clone().toDate()

            d.add 1, 'day'

        return holidays

    # Public factory method
    @GetHolidays: (countryCode) ->
        return new Holidays_Sweden()  if countryCode == 'SE'
        return new Holidays_Denmark() if countryCode == 'DK'
        return new Holidays_Norway()  if countryCode == 'NO'
        return null



class exports.Holidays_Sweden extends exports.Holidays

    _getHolidays: (year) =>
        holidays  = []
        easterDay = @_getEasterDate year # p�skdagen



        # Date based holidays 

        holidays.push new Date year,  0,  1 # ny�rsdagen den 1 januari
        holidays.push new Date year,  0,  6 # trettondedag jul den 6 januari
        holidays.push new Date year,  4,  1 # f�rsta maj
        holidays.push new Date year,  5,  6 # nationaldagen 6 juni
        holidays.push new Date year, 11, 25 # juldagen 25 december
        holidays.push new Date year, 11, 26 # annandag jul 26 december

        # midsommardagen den l�rdag som infaller under tiden 20-26 juni
        md = moment [year, 5, 20]
        md.add 1, 'day' while md.day() != @saturday
        holidays.push md.clone().toDate()

        # alla helgons dag den l�rdag som infaller under tiden 31 oktober-6 november
        d = moment [year, 9, 31]
        d.add 1, 'day' while d.day() != @saturday
        holidays.push d.clone().toDate()



        # Easter based holidays
        
        # l�ngfredagen fredagen n�rmast f�re p�skdagen
        d = moment(easterDay).subtract 1, 'day'
        d.subtract 1, 'day' while d.day() != @friday
        holidays.push d.clone().toDate()

        holidays.push easterDay # p�skdagen
        holidays.push moment(easterDay).add(1, 'day').toDate() # annandag p�sk

        # Kristi himmelsf�rdsdag sj�tte torsdagen efter p�skdagen
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @thursday
        holidays.push d.add(7*5, 'days').clone().toDate() 

        # pingstdagen sjunde s�ndagen efter p�skdagen
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @sunday
        holidays.push d.add(7*6, 'days').clone().toDate()



        # General free days

        holidays.push moment(easterDay).subtract(1, 'day').toDate() # p�skafton dagen innan p�skdagen
        holidays.push md.subtract(1, 'day').clone().toDate()        # midsommarafton dagen innan midsommardagen
        holidays.push new Date year, 11, 24                         # julafton 24 december
        holidays.push new Date year, 11, 31                         # ny�rsafton 31 december



        # Weekends
        @_addWeekends year, holidays
        return holidays



class exports.Holidays_Denmark extends exports.Holidays

    _getHolidays: (year) =>
        holidays  = []
        easterDay = @_getEasterDate year # p�skdagen



        # Date based holidays 

        holidays.push new Date year,  0,  1 # ny�rsdagen den 1 januari
        holidays.push new Date year,  0,  6 # trettondedag jul den 6 januari
        holidays.push new Date year, 11, 25 # juldagen 25 december
        holidays.push new Date year, 11, 26 # annandag jul 26 december

        # alla helgons dag den l�rdag som infaller under tiden 31 oktober-6 november
        d = moment [year, 9, 31]
        d.add 1, 'day' while d.day() != @saturday
        holidays.push d.clone().toDate()



        # Easter based holidays
        
        # sk�rtorsdag torsdagen n�rmast f�re p�skdagen
        d = moment(easterDay).subtract 1, 'day'
        d.subtract 1, 'day' while d.day() != @thursday
        holidays.push d.clone().toDate()
        
        # l�ngfredagen fredagen n�rmast f�re p�skdagen
        d = moment(easterDay).subtract 1, 'day'
        d.subtract 1, 'day' while d.day() != @friday
        holidays.push d.clone().toDate()

        holidays.push easterDay # p�skdagen
        holidays.push moment(easterDay).add(1, 'day').toDate() # annandag p�sk

        # Store bededag �r en officiell dansk och f�r�isk helgdag som infaller p� den fj�rde fredagen efter p�sk
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @friday
        holidays.push d.add(7*3, 'days').clone().toDate() 

        # Kristi himmelsf�rdsdag sj�tte torsdagen efter p�skdagen
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @thursday
        holidays.push d.add(7*5, 'days').clone().toDate() 

        # pingstdagen sjunde s�ndagen efter p�skdagen
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @sunday
        holidays.push d.add(7*6, 'days').clone().toDate()



        # General free days

        holidays.push moment(easterDay).subtract(1, 'day').toDate() # p�skafton dagen innan p�skdagen
        holidays.push new Date year, 11, 24                         # julafton 24 december
        holidays.push new Date year, 11, 31                         # ny�rsafton 31 december



        # Weekends
        @_addWeekends year, holidays
        return holidays



class exports.Holidays_Norway extends exports.Holidays

    _getHolidays: (year) =>
        holidays  = []
        easterDay = @_getEasterDate year # p�skdagen



        # Date based holidays 

        holidays.push new Date year,  0,  1 # ny�rsdagen den 1 januari
        holidays.push new Date year,  0,  6 # trettondedag jul den 6 januari
        holidays.push new Date year,  4,  1 # Arbeiderbevegelsens dag
        holidays.push new Date year,  4, 17 # Norges grunnlovsdag / nasjonaldag
        holidays.push new Date year, 11, 25 # juldagen 25 december
        holidays.push new Date year, 11, 26 # annandag jul 26 december

        # alla helgons dag den l�rdag som infaller under tiden 31 oktober-6 november
        d = moment [year, 9, 31]
        d.add 1, 'day' while d.day() != @saturday
        holidays.push d.clone().toDate()



        # Easter based holidays
        
        # sk�rtorsdag torsdagen n�rmast f�re p�skdagen
        d = moment(easterDay).subtract 1, 'day'
        d.subtract 1, 'day' while d.day() != @thursday
        holidays.push d.clone().toDate()
        
        # l�ngfredagen fredagen n�rmast f�re p�skdagen
        d = moment(easterDay).subtract 1, 'day'
        d.subtract 1, 'day' while d.day() != @friday
        holidays.push d.clone().toDate()

        holidays.push easterDay # p�skdagen
        holidays.push moment(easterDay).add(1, 'day').toDate() # annandag p�sk

        # Kristi himmelsf�rdsdag sj�tte torsdagen efter p�skdagen
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @thursday
        holidays.push d.add(7*5, 'days').clone().toDate() 

        # pingstdagen sjunde s�ndagen efter p�skdagen
        d = moment(easterDay).add 1, 'day'
        d.add 1, 'day' while d.day() != @sunday
        holidays.push d.add(7*6, 'days').clone().toDate()



        # General free days

        holidays.push moment(easterDay).subtract(1, 'day').toDate() # p�skafton dagen innan p�skdagen
        holidays.push new Date year, 11, 24                         # julafton 24 december
        holidays.push new Date year, 11, 31                         # ny�rsafton 31 december



        # Weekends
        @_addWeekends year, holidays
        return holidays
