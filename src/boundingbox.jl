call(::Type{AABB}, a::GPUArray) = AABB{Float32}(gpu_data(a))
call{T}(::Type{AABB{T}}, a::GPUArray) = AABB{T}(gpu_data(a))

call(::Type{AABB}, a::GPUArray) = AABB(gpu_data(a))
call(::Type{AABB}, a::GPUArray) = AABB(gpu_data(a))


particle_grid_bb{T}(min_xy::Vec{2,T}, max_xy::Vec{2,T}, minmax_z::Vec{2,T}) = AABB{T}(Vec(min_xy..., minmax_z[1]), Vec(max_xy..., minmax_z[2]))

Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Texture{Point{3, T2}, 1}, scale::Texture{Vec{3, T3}, 1}, primitive_bb) = AABB{T}(gpu_data(positions), gpu_data(scale), primitive_bb)
Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Texture{Point{3, T2}, 1}, scale::Vec{3, T3}, primitive_bb) = AABB{T}(gpu_data(positions), scale, primitive_bb)


function Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Vector{Point{3, T2}}, scale::Vec{3, T3}, primitive_bb)
    primitive_scaled_min = minimum(primitive_bb) .* scale
    primitive_scaled_max = maximum(primitive_bb) .* scale
    pmax = max(primitive_scaled_min, primitive_scaled_max)
    pmin = min(primitive_scaled_min, primitive_scaled_max)
    main_bb = AABB{T}(positions)
    AABB{T}(minimum(main_bb) + pmin, maximum(main_bb) + pmax)
end

function Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Vector{Point{3, T2}}, scale::Vector{Vec{3, T3}}, primitive_bb)
    _max = Vec{3, T}(typemin(T))
    _min = Vec{3, T}(typemax(T))
    for (p, s) in zip(positions, scale)
        p = Vec{3, T}(p)
        s_min = Vec{3, T}(s) .* minimum(primitive_bb)
        s_max = Vec{3, T}(s) .* maximum(primitive_bb)
        s_min_r = min(s_min, s_max)
        s_max_r = max(s_min, s_max)
        _min = min(_min, p + s_min_r)
        _max = max(_max, p + s_max_r)
    end
    AABB{T}(_min, _max)
end
