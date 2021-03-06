function __init__()
  @require Distributions="31c24e10-a181-5473-b8eb-7969acd0382f" begin
    handle_distribution_u0(_u0::Distributions.Sampleable) = rand(_u0)
  end

  @require ForwardDiff="f6369f11-7733-5829-9624-2563aa707210" begin
    # Support adaptive with non-dual time
    @inline function ODE_DEFAULT_NORM(u::AbstractArray{<:ForwardDiff.Dual,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((ForwardDiff.value(x) for x in u),t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::Array{<:ForwardDiff.Dual,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((ForwardDiff.value(x) for x in u),t)) / length(u))
    end
    @inline ODE_DEFAULT_NORM(u::ForwardDiff.Dual,t) = abs(ForwardDiff.value(u))

    # When time is dual, it shouldn't drop the duals for adaptivity
    @inline function ODE_DEFAULT_NORM(u::AbstractArray{<:ForwardDiff.Dual,N},t::ForwardDiff.Dual) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((x for x in u),t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::Array{<:ForwardDiff.Dual,N},t::ForwardDiff.Dual) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((x for x in u),t)) / length(u))
    end
    @inline ODE_DEFAULT_NORM(u::ForwardDiff.Dual,t::ForwardDiff.Dual) = abs(u)

    # Type piracy. Should upstream
    Base.nextfloat(d::ForwardDiff.Dual{T,V,N}) where {T,V,N} = ForwardDiff.Dual{T}(nextfloat(d.value), d.partials)
    Base.prevfloat(d::ForwardDiff.Dual{T,V,N}) where {T,V,N} = ForwardDiff.Dual{T}(prevfloat(d.value), d.partials)
  end

  @require Measurements="eff96d63-e80a-5855-80a2-b1b0885c5ab7" begin
    # Support adaptive steps should be errorless
    @inline function ODE_DEFAULT_NORM(u::AbstractArray{<:Measurements.Measurement,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((Measurements.value(x) for x in u),t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::Array{<:Measurements.Measurement,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((Measurements.value(x) for x in u),t)) / length(u))
    end
    @inline ODE_DEFAULT_NORM(u::Measurements.Measurement,t) = abs(Measurements.value(u))
  end

  @require Unitful="1986cc42-f94f-5a68-af5c-568840ba703d" begin
    # Support adaptive errors should be errorless for exponentiation
    value(x::Unitful.Quantity) = x.val
    @inline function ODE_DEFAULT_NORM(u::AbstractArray{<:Unitful.Quantity,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((value(x) for x in u),t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::Array{<:Unitful.Quantity,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((value(x) for x in u),t)) / length(u))
    end
    @inline ODE_DEFAULT_NORM(u::Unitful.Quantity,t) = abs(value(u))
  end

  @require Flux="587475ba-b771-5e3f-ad9e-33799f191a9c" begin
    value(x::Flux.Tracker.TrackedReal)  = x.data
    value(x::Flux.Tracker.TrackedArray) = x.data

    # Support adaptive with non-tracked time
    @inline function ODE_DEFAULT_NORM(u::Flux.Tracker.TrackedArray,t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((value(x) for x in u),t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::AbstractArray{<:Flux.Tracker.TrackedReal,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((value(x) for x in u),t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::Array{<:Flux.Tracker.TrackedReal,N},t) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip((value(x) for x in u),t)) / length(u))
    end
    @inline ODE_DEFAULT_NORM(u::Flux.Tracker.TrackedReal,t) = abs(value(u))

    # Support TrackedReal time, don't drop tracking on the adaptivity there
    @inline function ODE_DEFAULT_NORM(u::Flux.Tracker.TrackedArray,t::Flux.Tracker.TrackedReal) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip(u,t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::AbstractArray{<:Flux.Tracker.TrackedReal,N},t::Flux.Tracker.TrackedReal) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip(u,t)) / length(u))
    end
    @inline function ODE_DEFAULT_NORM(u::Array{<:Flux.Tracker.TrackedReal,N},t::Flux.Tracker.TrackedReal) where {N}
      sqrt(sum(x->ODE_DEFAULT_NORM(x[1],x[2]),zip(u,t)) / length(u))
    end
    @inline ODE_DEFAULT_NORM(u::Flux.Tracker.TrackedReal,t::Flux.Tracker.TrackedReal) = abs(u)
  end

end
