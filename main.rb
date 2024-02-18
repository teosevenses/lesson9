# frozen_string_literal: true

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'wagon'
require_relative 'passenger_wagon'
require_relative 'cargo_wagon'

class Main
  def initialize
    @wagons = []
    @trains = []
    @routes = []
    @stations = []
  end

  def start
    puts 'Управление поездами'
    loop do
      menu
      choice = gets.chomp
      break if choice == '99'

      list(choice)
    end
  end

  private

  attr_reader :trains, :stations, :routes, :wagons

  def menu
    puts "
		1 - Создать станцию
		2 - Создать поезда
		3 - Создать маршруты
		4 - Добавить станцию на маршрут
		5 - Удалить станцию с маршрута
		6 - Список маршрутов
		7 - Просматривать список станций
		8 - Просматривать список поездов
		9 -  Назначать маршрут поезду
		10 - Перемещать поезд по маршруту вперед
		11 - Перемещать поезд по маршруту назад
		12 - Прицеплять вагон
		13 - Просматривать список поездов на станции
		14 - Список вагонов поезда
		15 - Занять место в вагоне
		99 - Выйти из меню
		"
  end

  def list(choice)
    case choice
    when '1'
      create_station
    when '2'
      create_train
    when '3'
      create_route
    when '4'
      add_route
    when '5'
      delete_route
    when '6'
      list_routes
    when '7'
      list_stations
    when '8'
      list_trains
    when '9'
      assign_route
    when '10'
      move_forward
    when '11'
      move_back
    when '12'
      attach_wagon
    when '13'
      show_trains_on_station
    when '14'
      show_train_wagons
    when '15'
      place_in_wagon
    end
  end

  def create_station
    puts 'Введите название станции'
    name = gets.chomp
    station = Station.new(name)
    puts "Произошло создание станции #{name}"
    stations << station
  rescue Station::ValidationError => e
    puts e.message
    retry
  end

  def create_train
    puts "Введите тип поезда\n0 - Грузовой\n1 - Пассажирский"
    type = gets.chomp
    puts 'Введите номер поезда'
    num = gets.chomp
    train = (type == '0' ? CargoTrain : PassengerTrain).new(num)
    trains << train
    puts "Создан #{train.type} поезд"
  rescue Train::ValidationError => e
    puts e.message
    retry
  end

  def list_stations
    puts 'Список станций'
    stations.each_with_index do |x, y|
      puts "#{y}. #{x.name}"
    end
  end

  def create_route
    start_station = select_station('Выберите начальную станцию по номеру из списка ниже')
    finish_station = select_station('Выберите конечную станцию по номеру из списка ниже')

    route = Route.new(start_station, finish_station)
    routes << route
    puts 'Создан маршрут поезда'
  end

  def select_station(message)
    puts message
    list_stations
    stations[gets.chomp.to_i]
  end

  def list_routes
    puts 'Список маршрутов'
    routes.each_with_index do |x, y|
      puts "#{y} #{x.readable_stations}"
    end
  end

  def add_route
    puts 'Выберите маршрут и станцию из списка ниже:'
    list_routes
    route = routes[gets.chomp.to_i]
    list_stations
    station = stations[gets.chomp.to_i]
    unless route || station
      puts 'Данный маршрут или станция отсутствует'
      return
    end
    route.add_station(station)
    puts 'Станция добавлена в маршрут'
  end

  def delete_route
    puts 'Выберите станцию и маршрут'

    list_routes
    route = routes[gets.chomp.to_i]

    route.list_stations
    second_input = gets.chomp.to_i

    if (deleted_station = route.stations.delete_at(second_input))
      puts "Станция #{second_input} #{deleted_station.name} удалена"
    else
      puts "Станция под номером #{second_input} не найдена"
    end
  end

  def assign_route
    puts 'Выбрать маршрут'
    list_routes
    route = routes[gets.chomp.to_i]

    puts 'Выбрать поезд'
    list_trains
    train = trains[gets.chomp.to_i]

    train.assign_route(route)
    puts "Выбранный поезд #{train.num} назначен на выбранный маршрут #{route.name}"
  end

  def list_trains
    puts 'Список поездов'
    trains.each_with_index do |x, y|
      puts "#{y} #{x.type} #{x.num}"
    end
  end

  def show_trains_on_station
    list_stations
    input = gets.chomp.to_i
    station = stations[input]
    station.yield_trains do |train|
      puts "Номер поезда: #{train.num}, тип: #{train.type}, количество вагонов #{train.wagons.count}"
    end
  end

  def show_train_wagons
    list_trains
    input = gets.chomp.to_i
    train = trains[input]
    train.yield_wagons do |wagon|
      puts "Номер вагона: #{wagon.num}, тип #{wagon.type}, кол-во свободного места: #{wagon.free_place}"
    end
  end

  def move_forward
    list_trains
    input = gets.chomp.to_i
    train = trains[input]
    train.move_forward
    puts 'Поезд на следующей станции'
  end

  def move_back
    list_trains
    input = gets.chomp.to_i
    train = trains[input]
    train.move_back
    puts 'Поезд на предыдущей станции'
  end

  def attach_wagon
    list_trains
    train = trains[gets.chomp.to_i]
    num = train.wagons.count + 1
    if train.type == :passenger
      train.wagons << PassengerWagon.new(num, 100)
      puts 'Пассажирский вагон прицеплен'
    elsif train.type == :cargo
      train.wagons << CargoWagon.new(num, 500)
      puts 'Грузовой вагон прицеплен'
    end
  end

  def place_in_wagon
    list_trains
    train = trains[gets.chomp.to_i]
    train.yield_wagons do |wagon|
      puts "Номер вагона: #{wagon.num}, тип #{wagon.type}, кол-во свободного места: #{wagon.free_place}"
    end
    puts 'Введите номер вагона'
    wagon = train.wagons.find { |x| x.num == gets.chomp.to_i }
    if wagon.type == :passenger
      wagon.take_place
    else
      (puts 'Какой объем нужно занять'

       wagon.take_place(gets.chomp.to_i)
       puts 'Вводимый объем превышает объем вагона по умолчанию' if wagon.free_place.negative?)
    end
  end
end

f = Main.new
f.start
