#pragma once

#include "drape/drape_global.hpp"
#include "drape/binding_info.hpp"
#include "drape/index_buffer_mutator.hpp"
#include "drape/attribute_buffer_mutator.hpp"

#include "indexer/feature_decl.hpp"

#include "geometry/screenbase.hpp"
#include "geometry/point2d.hpp"
#include "geometry/rect2d.hpp"

#include "base/buffer_vector.hpp"

namespace dp
{

class OverlayHandle
{
public:
  typedef vector<m2::RectF> Rects;

  OverlayHandle(FeatureID const & id,
                dp::Anchor anchor,
                double priority);

  virtual ~OverlayHandle() {}

  bool IsVisible() const;
  void SetIsVisible(bool isVisible);

  bool IsValid() const { return m_isValid; }

  virtual void Update(ScreenBase const & /*screen*/) {}
  virtual m2::RectD GetPixelRect(ScreenBase const & screen) const = 0;

  virtual void GetPixelShape(ScreenBase const & screen, Rects & rects) const = 0;

  bool IsIntersect(ScreenBase const & screen, OverlayHandle const & h) const;

  uint16_t * IndexStorage(uint16_t size);
  size_t GetIndexCount() const;
  void GetElementIndexes(RefPointer<IndexBufferMutator> mutator) const;
  virtual void GetAttributeMutation(RefPointer<AttributeBufferMutator> mutator, ScreenBase const & screen) const;

  bool HasDynamicAttributes() const;
  void AddDynamicAttribute(BindingInfo const & binding, uint16_t offset, uint16_t count);

  FeatureID const & GetFeatureID() const;
  double const & GetPriority() const;

protected:
  void SetIsValid(bool isValid) { m_isValid = isValid; }

protected:
  FeatureID const m_id;
  dp::Anchor const m_anchor;
  double const m_priority;

  typedef pair<BindingInfo, MutateRegion> TOffsetNode;
  TOffsetNode const & GetOffsetNode(uint8_t bufferID) const;

private:
  bool m_isVisible;
  bool m_isValid;

  vector<uint16_t> m_indexes;
  struct LessOffsetNode
  {
    bool operator()(TOffsetNode const & node1, TOffsetNode const & node2) const
    {
      return node1.first.GetID() < node2.first.GetID();
    }
  };

  struct OffsetNodeFinder;

  set<TOffsetNode, LessOffsetNode> m_offsets;
};

class SquareHandle : public OverlayHandle
{
  typedef OverlayHandle base_t;
public:
  SquareHandle(FeatureID const & id,
               dp::Anchor anchor,
               m2::PointD const & gbPivot,
               m2::PointD const & pxSize,
               double priority);

  virtual m2::RectD GetPixelRect(ScreenBase const & screen) const;
  virtual void GetPixelShape(ScreenBase const & screen, Rects & rects) const;

private:
  m2::PointD m_gbPivot;
  m2::PointD m_pxHalfSize;
};

} // namespace dp
