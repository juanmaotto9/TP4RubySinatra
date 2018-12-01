require_relative 'carrito'

class Usuario
	attr_accessor :nombre_usuario, :mi_carrito

	def initialize(un_hash)
		@nombre_usuario= un_hash[:nombre]
		@mi_carrito= nil
	end


	def crear_carrito 
		#crea un carrito
		@mi_carrito = Carrito.new
	end


	def hay_carrito?

		#devuelve true en caso de que haya carrito
		!@mi_carrito.nil?
	end


	def tus_items

		#Obtiene los items de su carrito
		@mi_carrito.mis_items_personales
	end

	def imprimir

		#imprime algunos datos requeridos
		{
			nombre:@nombre_usuario,
			items:@mi_carrito.mis_items_reducidos,
			fecha_creacion:@mi_carrito.fecha_creacion,
			precio:@mi_carrito.monto_total
		}
	end


	def usr_agregar_item(un_item)

		#agrega "un item" a su carrito
		@mi_carrito.agregar_item(un_item)
	end


	def borrar_del_carrito(item)

		#elimina el item "un_item" del carrito
		@mi_carrito.borrar_item(item)
	end

end